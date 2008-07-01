From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 01 Jul 2008 16:25:06 +0200
Message-ID: <486A3E42.9000009@trash.net>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <20080701130835.GA29223@2ka.mipt.ru> <alpine.LNX.1.10.0807011623340.12878@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0807011623340.12878@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Tuesday 2008-07-01 15:08, Evgeniy Polyakov wrote:
>   
>>>> I'm not sure it is that simple. OSF uses common rules database
>>>> shared with OpenBSD (and other *BSDs as well), so converting it into u32
>>>> match would require noticeble efforts. But in theory it is probably
>>>> doable.
>>>>         
>>> This would be preferrable in my opinion since they both allow
>>> programmable filters, but u32 appears to be more flexible. I'm
>>> very reluctant to add new iptables modules that don't increase
>>> expressiveness or provide other clear benefits since we already
>>> have an insane amount of modules.
>>>       
>
> An iptables extension which you can use with -m osf --genre Linux
> but which internally uses xt_u32.ko would be the perfect solution
> ATM IMO. It would require a number of changes to the iptables API
> though...
>   

I agree that this would be much nicer. I assume you would either need
a way to associate multiple matches with a single userspace extension
or a much more intelligent parser in userspace?

