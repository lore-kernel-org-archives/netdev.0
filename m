From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/1] More ethtool support for sis900 (with locking)
Date: Sun, 6 Mar 2005 11:01:32 +0100
Message-ID: <15e3c357f5586727c04c81a091cb809c@libero.it>
References: <20050305210745.6763.6618@localhost.localdomain> <20050305212838.GD25116@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20050305212838.GD25116@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On 05/mar/05, at 22:28, Francois Romieu wrote:

> Daniele Venzano <webvenza@libero.it> :
> [...]
>> Index: sis900.c
>> ===================================================================
>> --- a/drivers/net/sis900.c	(revision 95)
>> +++ b/drivers/net/sis900.c	(revision 98)
> [...]
>> @@ -1943,10 +1952,47 @@
>>  	sis_priv->msg_enable = value;
>>  }
>>
>> +static u32 sis900_get_link(struct net_device *net_dev)
>> +{
>> +	struct sis900_private *sis_priv = net_dev->priv;
>
> Any reason to not use netdev_priv() ?
I'm keeping the style of the rest of the driver, when more pressing 
issues (wol, netconsole, weird behaviour in suspend/resume) are solved 
I'll convert the whole source to netdev_priv().

> I would not mind an empty line between the declaration of variables
> and the actual code.
It seemed to me a waste of space, as the functions are so small and 
obvious.

Thanks for the feedback.

--
Daniele Venzano
http://www.brownhat.org
