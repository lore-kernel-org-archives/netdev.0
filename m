From: c4p7n1@capitanio.org
Subject: Re: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Fri, 25 Jul 2008 15:43:54 +0200 (MEST)
Message-ID: <200807251343.m6PDhsHs006002@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Edward Hsu" <edward_hsu@realtek.com.tw>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from em-p00-ob.rzone.de ([81.169.146.225]:36560 "EHLO
	em-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbYGYNoD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 09:44:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu<romieu@fr.zoreil.com>:
> c4p7n1@capitanio.org <c4p7n1@capitanio.org> :
> [...]
> > It only remains other (cosmetic?) not-linux-only issue: the *E chip-sets
> have
> > a built in 100Mb/s transceiver
> > 
> >
> http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PNid=14&PFid=7
> &Level=5&Conn=4&ProdID=19
> > 
> > but the driver advertises 1G:
> > 
> > Settings for eth0:
> > 	Supported ports: [ TP ]
> > 	Supported link modes:   10baseT/Half 10baseT/Full 
> > 	                        100baseT/Half 100baseT/Full 
> > 	                        1000baseT/Full 
> 
> Ahem.
Yes, development can run backward ;-)
> 
> Can you give the completely untested patch below a try (say, against
> 2.6.26 or more) ?
Sure, as soon as I have that laptop in my hands.

--------------

Hm, I g*led a bit and found a point where the communication between you
and Edward from Realtek ends. ( http://lkml.org/lkml/2007/2/6/478 )

That raises a lot of questions in my head. Kids I'm teaching cs keep asking me,
why they should develop OS software and I am always trying to figure out an
unbiased point of view.

So, let me rewind the time machine to February 2007.
>>I think I didn't make it clear about the programming manuals for PCI-E ICs.
>>Due to several legal issues, Realtek won't put the programming guide on 
>>its website. However, Realtek does offer the programming guide if the 
>>customers need it. If you want to have a copy of it, please contact 
>>Realtek FAE<ryankao@realtek.com.tw>.
>Does it mean that the documentation is NDAed ?
>ANS:
>No, you don't have to sign anything.
Francois, why didn't you take that offer?
Was there any other problems with that documentation?
Would you develop that driver and actually read that documentation?
Would available documentation cause a lost of interest developing OS driver
in the free time?
I see something like that by the kids. That may be a part of human nature.

>> Sure! You are right. RTL8110SC, RTL8111B and RTL8101E have modest
>> differences, now. However, RTL8101E is a PCI-E fast ethernet controller.
>> I don't think is a good idea to merge its Linux driver into r8168.c or
>> r8169.c. RTL8110SC is the final version of Realtek PCI gigabit ethernet
>> controller. Moreover, due to the increasing popularity of PCI-E, Realtek
>> is going to design several generations of PCI-E ethernet controllers to
>> satisfy customer requests. I have discussed this issue with my hardware
>> colleagues. They believe that both MAC register layout and tx/rx
>> descriptor layout will be changed a lot in new PCI-E ICs. Actually, they
>> already did. Therefore, the hardwares of RTL8111B(PCI-E gigabit
>> ethernet) and RTL8101E(PCI-E fast ethernet) will have frequent and
>> drastic changes. So, I think that it's a good moment to separate their
>> Linux drivers, and r8169.c can become stable.
>Well, code and facts will tell. :o)

I see the code, but don't see any facts or reasoning.
Is it easier to develop one driver for everything or why are you doing that?
Could you guys find some compromise and start working together again?
Eventually splitting in 1G/100M driver? From a practical point of view I
would'n expect finding an 100M chipset in an 1G menuconfig entry. 

It's a foreign language and my outside view may be completely wrong,
I hope that's obvious...

Thanks
	Martin Capitanio

