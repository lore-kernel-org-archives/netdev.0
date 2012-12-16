From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 05:26:02 -0500
Message-ID: <50CDA1BA.4080702@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121216002755.GA11773@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On 12-12-15 07:27 PM, Pablo Neira Ayuso wrote:

> The binary interface was broken in 1.4.11 with the guided option
> parser:

Ah. Thanks that would explain it.


> You need a patch to use the new interface to stay in sync with current
> iptables libraries. I'll make it for tc and send it to you.
>

Much thanks. I just scanned it and things have changed; old way used to 
take multiparams. New one a single struct, so would have taken much 
longer for me to resolve.

> BTW, I think it would be good if we find the way to check for
> libxtables current version (see iptables/configure.ac), so you can
> know that we broke binary compatibility again.
>

will do.

cheers,
jamal
