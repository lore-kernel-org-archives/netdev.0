From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 11:45:02 -0800
Message-ID: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So I'm the one who long ago asked for some of the more esoteric
netfilter configuration questions to be hidden behind some "advanced"
question, and thus the reason why a lot of them are behind that
NETFILTER_ADVANCED Kconfig setting.

However, I'm now trying OpenSUSE on one of my laptops, and it looks
like the RAW filter is used by the default OS iptables setup. The fact
that it is hidden behind NETFILTER_ADVANCED now means that I either
have to enable the advanced netfilter Kconfig questions, or we should
just remove the "depends on NETFILTER_ADVANCED" for the RAW case (or,
rather - caseS - since there's a separate raw filter for ipv4 and
ipv6, which sounds odd in itself, but that's another issue entirely)

My gut feel is that if it's one of the filters that a major distro
depends on by default, it should no longer be hidden. But honestly, I
didn't look at *why* OpenSUSE uses that filter. Maybe it's just doing
something really odd and crazy.

Comments?

                           Linus
