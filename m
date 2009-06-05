From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 05 Jun 2009 15:30:13 +0200
Message-ID: <4A291DE5.9040802@trash.net>
References: <20090604162212.GA24661@ioremap.net> <4A290767.6080202@trash.net> <alpine.LSU.2.00.0906051508300.17010@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0906051508300.17010@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Friday 2009-06-05 13:54, Patrick McHardy wrote:
>   
>>> +
>>> +		if (optsize > sizeof(opts))
>>> +			optsize = sizeof(opts);
>>>       
>> How can this happen? The doff field can only represent up to 40
>> bytes of option length.
>>     
>
> Forged packets?

How would that increase the size of the doff field? :)
>>> +	printk(KERN_INFO "Started passive OS fingerprint matching module.\n");
>>>       
>> Please no messages on successful module load. Or at least
>> not when statically built, but preferrably not at all.
>>     
>
> By that logic should not the messages-on-load for netfilter be removed? ;-)
>   

I wouldn't care, but there's a difference between the main module printing a
message and extensions printing a message.

