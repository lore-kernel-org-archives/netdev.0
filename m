From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 12:47:13 -0500
Message-ID: <50CE0921.7060306@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-16 12:21 PM, Jan Engelhardt wrote:
>
>
> As you can see, the old ->parse() that goes back to libxtables.so.0
> still remains. It's just that... only 5 out of 99 plugins still come
> with an old parse function.
>

I see.
So calling m->XXX may not be a wise long term solution.
Hasan's patch has a call to xtables_option_tpcall(), if that is the 
right interface I hope that going forward if any of the m->parseXX
changes you will take care of hiding all that stuff.

> old parse has not entered any deprecation stage yet, since there are still
> plugins out there (both the 5 and external ones) that make use of it.
> Right now, both parse and x6_parse are valid.
>

True - but we are getting broken because we are using a call that only 5 
or so users provide. It would have saved us time if we got the
a good log message instead of checking for if !m->parse()

> Yes, all those with an x6_ prefix are new.
> Mh, I already dream of plans reducing m_xt to something that
> does not require libxtables.so anymore.
>

That would be nice - but someone is going to have to link to libxtables, no?

cheers,
jamal
