From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Thu, 29 Nov 2007 18:14:18 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711291813200.13075@fbirervta.pbzchgretzou.qr>
References: <11955644701165-git-send-email-panther@balabit.hu>
 <1195564470928-git-send-email-panther@balabit.hu>
 <11955644702451-git-send-email-panther@balabit.hu>
 <11955644701536-git-send-email-panther@balabit.hu>
 <11955644702194-git-send-email-panther@balabit.hu> <20071123133933.GA31396@innominate.com>
 <474EB585.30407@balabit.hu> <474EE5C6.9070500@trash.net> <474EE79F.2000409@balabit.hu>
 <474EE86E.2010201@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: panther@balabit.hu, Lutz Jaenicke <ljaenicke@innominate.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <474EE86E.2010201@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 29 2007 17:27, Patrick McHardy wrote:
>
>> The syntax "name/0xmask" is simply too strange for me.
>
> Then how about name/name with masks also defined in rt_ifgroup?
> The same question applies for marks of course.
>
I would find that confusing, which is why the new xt_TOS only
allows names when no /mask or a mask of /allbits is used.

>> > > > There is no standard API like getservbyname()...
>> > >
>> > > The code of iproute2 should be copied. If Patrick says it is ok,  I'll
>> > > write this part.
>> >
>> > Of course. Please put the tab part somewhere common, I always
>> > wanted to have named firewall marks shared with ip and tc
>> > and I believe Balazs wanted that too :)
>> 
>> Ok. Yes, he wants :)
>
So, we are going to see a librtnl?
