From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 5 Sep 2008 00:18:06 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0809050012400.17569@fbirervta.pbzchgretzou.qr>
References: <20080821220432.GT31136@x200.localdomain> <48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080905025838.GA2789@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2008-09-04 22:58, Alexey Dobriyan wrote:

>In conntrack_mt_v0() "ct->status" can be used even for untracked connection,
>is this right?

Yes.

>For example, does setting IPS_NAT_DONE_MASK and IPS_CONFIRMED_BIT on
>untracked conntracked really necessary?

Does it even happen? Something smells afoul if ct->status is anything
but zero/unset for the untracked entry.

