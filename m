From: Alejandro Bonilla <abonilla@linuxwireless.org>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 21:46:27 -0500
Message-ID: <42A8FF03.3010508@linuxwireless.org>
References: <200506090909.55889.vda@ilport.com.ua>	<20050608.231657.59660080.davem@davemloft.net>	<20050609104205.GD3169@elf.ucw.cz> <20050609.125324.88476545.davem@davemloft.net> <42A8AE2A.4080104@linux.intel.com> <42A8F758.2060008@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, pavel@ucw.cz,
	vda@ilport.com.ua, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262417AbVFJDqs@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42A8F758.2060008@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> James Ketrenos wrote:
>
>> I don't know if all the distributions have moved away from this 
>> model. If they have and the devices are brought up regardless of 
>> link, then
>> going back to delaying radio initialization until the open() is called
>> is workable. 
>
>
>
> When the interface is not up, we ideally want the device to be as 
> passive as possible.
>
> Most net drivers shut down as much as possible at dev->close() time, 
> and it would really be good if wireless drivers followed suit.
>
>     Jeff
>
>
>
OK. I understand the point and I totally agree with this. We really want 
the adapter to just do what the user or profiles ask the adapter to do. 
Yes, in an ideal world.

Let's talk about easyness. These adapters are in laptops. You don't want 
to type a lot of stop everytime you move from access points, reboots and 
so on. In a server enviroment with the ethernet adapters, we really just 
want them to do what they do and we have scripts for it. So, again, with 
mobile is different. An association on boot is fair and really OK. You 
are not really doing dhcp requests on boot and trying to get the 
internet from people for free. You just want you adapter running faster, 
get connected and get over whatever you have to do to start working or 
whatsoever.

Let's really think what would be the nicest way that the card should 
behave, after all if the adapter just associates, you are not really 
stealing any Internet. :)

Association on boot is how it has worked all the time, and in the 18 
months of the project, nobody has complained about it... So... I wonder, 
users are happy with it? (I know it might not be the correct way)

Just a thought.

.Alejandro
