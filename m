From: matthieu castet <castet.matthieu@free.fr>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for
 ATM devices (updated)
Date: Fri, 04 Feb 2005 19:27:07 +0100
Message-ID: <4203BE7B.2030503@free.fr>
References: <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
        usbatm@lists.infradead.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
In-Reply-To: <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

chas williams - CONTRACTOR wrote:
> In message <20050121085123.GA2471@katya>,Roman Kagan writes:
> 
>>The patch is against 2.6.10.  Please comment.
> 
> 
> i guess i would prefer that entries be named typeN, like he0
> instead of just a number.
> 
> you were printing 7 octets for the address.
> 
> if !CONFIG_SYSFS, then __free_atm_dev() is going to need to do the
> kfree.
> 
> i added some other fields that i think are interesting.
> 
> comments?
> 
> +
> +static ssize_t show_carrier(struct class_device *cdev, char *buf)
> +{
> +	char *pos = buf;
> +	struct atm_dev *adev = to_atm_dev(cdev);
> +
> +	pos += sprintf(pos, "%d\n",
> +		       adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
> +		
> +	return pos - buf;
> +}
Shouldn't adev->signal == ATM_PHY_SIG_FOUND ? 1 : 0); be better : in the 
case of ATM_PHY_SIG_UNKNOWN, it return 1...


Matthieu
