From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 21:04:36 +0300
Message-ID: <15ddcffd0905141104u585ddd59q632c53d30c5f8b18@mail.gmail.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>
	 <200905142128.58111.rusty@rustcorp.com.au>
	 <4A0C2500.7090709@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, Gregory Haskins <ghaskins@novell.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:59936 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbZENSEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 14:04:37 -0400
Received: by bwz22 with SMTP id 22so1455045bwz.37
        for <netdev@vger.kernel.org>; Thu, 14 May 2009 11:04:37 -0700 (PDT)
In-Reply-To: <4A0C2500.7090709@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2009 at 5:04 PM, Or Gerlitz <ogerlitz@voltaire.com> wrote:

> In my case, both the guest and the host run 2.6.29.1 and I use ethX (igb based) --
> bridge -- tapY <--> qemu configuration

oops, this failure happens when I used IP forwarding scheme between
tap0 to IB NIC which BTW didn't support offloads the way it was
configured. I don't see how it matters for the crash, but I will
retest with a bridge based config early next week and let you know.

Or.
