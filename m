From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 00/17] netfilter: IPv6 NAT
Date: Mon, 21 Nov 2011 18:01:12 +0100
Message-ID: <4ECA83D8.6050309@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net> <alpine.LNX.2.01.1111211402350.25806@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ulrich.weber@sophos.com
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111211402350.25806@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/21/2011 02:05 PM, Jan Engelhardt wrote:
> On Monday 2011-11-21 06:45, kaber@trash.net wrote:
>
>> net/ipv4/netfilter/ipt_REDIRECT.c                  |   23 +-
>> .../{nf_nat_standalone.c =>  iptable_nat.c}         |  265 ++++-----
>> net/ipv4/netfilter/nf_nat_irc.c                    |    4 +-
>> net/netfilter/nf_conntrack_sip.c                   |  119 +++--
> Pablo once hinted that the patches (and not just the diffstat) should
> also be produced using move semantics rather than the delete-add cycle,
> for the reader's benefit. To do this, so I have found, one can use
>
>   git send-email ... --format-patch -M

Yeah, I didn't use -M this time so people can test the patches
by applying them directly. I'll add it during the next submission
after setting up a public git tree.

