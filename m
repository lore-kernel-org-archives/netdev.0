From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path similar to hw-accel
Date: Sat, 21 May 2011 23:34:47 -0700
Message-ID: <m17h9jp7js.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51399 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab1EVGez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 02:34:55 -0400
In-Reply-To: <20110522062915.GA2611@jirka.orion> (Jiri Pirko's message of
	"Sun, 22 May 2011 08:29:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> writes:

> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.com wrote:
>
> <snip>
>>
>>And because some setups may still require the skb not to be untagged,
>>may be we need the ability to re-tag the skb in some situations...
>>When a protocol handler or rx_handler is explicitly registered on a
>>net_device which expect to receive tagged skb, we should deliver
>>tagged skb to it... Arguably, this may sound incredible for the
>>general case, but may be required for not-so-special cases like
>>bridge or protocol analyzer.
>
> Wait, what setups/code require the skb not to be untagged? If there's
> such, it should be fixed.

tcpdump on the non-vlan interface for one.

Eric
