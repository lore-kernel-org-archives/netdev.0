From: Benjamin Reed <breed@almaden.ibm.com>
Subject: Re: [PATCH] Dynamic airo.c patch for 2.6.10
Date: Wed, 02 Feb 2005 11:16:11 -0800
Message-ID: <420126FB.3000007@almaden.ibm.com>
References: <20050202183525.GA13881@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Javier Achirica <achirica@ttd.net>, netdev@oss.sgi.com
To: jt@hpl.hp.com
In-Reply-To: <20050202183525.GA13881@bougret.hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm wondering if it would be possible to change IW_ENCODE_TEMP to 
IW_ENCODE_PERM. I realize that would not be backward compatible, but as 
you point out, the default assumption is that the keys are volatile.

ben

Jean Tourrilhes wrote:

>Benjamin Reed wrote :
>  
>
>>Here is a patch for the 2.6.10 aironet driver that
>>will enable dynamic wep keying without resetting the
>>MAC. It allows us to use xsupplicant with the driver.
>>
>>There are two lines of ugliness (the ones with the 0
>>&&) where I ignore the flag that says wether we are
>>setting a permanent or a temporary key since
>>xsupplicant doesn't use the IW_ENCODE_TEMP flag.
>>    
>>
>
>	The IW_ENCODE_TEMP flag only make sense for the Aironet
>driver, as for all other hardware the WEP keys are volatile. So, don't
>expect this flag to be widespread.
>	I would suggest you send a nice little patch to the maintainer
>of xsupplicant (and wpa_supplicant as well) explaining the
>situation. Enabling this flag should not affect other drivers, and
>might actually be a good idea in general.
>	Have fun...
>
>	Jean
>  
>
