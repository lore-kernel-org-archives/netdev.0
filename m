From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 16:38:45 +0800
Message-ID: <BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, ebiederm@xmission.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f52.google.com ([209.85.214.52]:47192 "EHLO
	mail-bw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab1EVIjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 04:39:06 -0400
Received: by bwj24 with SMTP id 24so5997686bwj.11
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 01:39:05 -0700 (PDT)
In-Reply-To: <20110522062915.GA2611@jirka.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2011 at 2:29 PM, Jiri Pirko <jpirko@redhat.com> wrote:
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
>

For a transparent bridge with ports: eth0 and eth1, the vlan tags
need to be preserved.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
