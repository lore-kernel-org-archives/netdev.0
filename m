From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 16:26:06 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0807011623340.12878@fbirervta.pbzchgretzou.qr>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <20080701130835.GA29223@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080701130835.GA29223@2ka.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2008-07-01 15:08, Evgeniy Polyakov wrote:
>> >
>> >I'm not sure it is that simple. OSF uses common rules database
>> >shared with OpenBSD (and other *BSDs as well), so converting it into u32
>> >match would require noticeble efforts. But in theory it is probably
>> >doable.
>> 
>> This would be preferrable in my opinion since they both allow
>> programmable filters, but u32 appears to be more flexible. I'm
>> very reluctant to add new iptables modules that don't increase
>> expressiveness or provide other clear benefits since we already
>> have an insane amount of modules.

An iptables extension which you can use with -m osf --genre Linux
but which internally uses xt_u32.ko would be the perfect solution
ATM IMO. It would require a number of changes to the iptables API
though...
