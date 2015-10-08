From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/3] net: Add driver helper function to determine if
 checksum is offloadable
Date: Thu, 8 Oct 2015 08:48:42 -0700
Message-ID: <CALx6S37f8jccJsY4UHo_ZocSO6XFD+8uPMtqjgMOHPA2nOuaWw@mail.gmail.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
	<1444316982.92154.2.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36738 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964818AbbJHPsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:48:43 -0400
Received: by igcrk20 with SMTP id rk20so15975912igc.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 08:48:42 -0700 (PDT)
In-Reply-To: <1444316982.92154.2.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 8:09 AM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Mon, 2015-10-05 at 16:39 -0700, Tom Herbert wrote:
>> This patch defines a helper function that drivers can call to check
>> if it is able to offload the checksum for a particular packet.
>
> It occurs to me that by itself, this doesn't actually fix the problem.
> We'd then need to go over all drivers which currently use
> NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM, and convert them. Would that be
> the intention?
>
In time, yes. But in the near future, I would like to be able to state
that NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM are being deprecated and
that new drivers can only implement NETIF_F_HW_CSUM interface.
Hopefully, this will encourage HW vendors to implement the generic,
non-protocol specific checksum algorithms in new devices.

Tom

> --
> dwmw2
>
