From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH V2 net-next 0/2] liquidio: Add support for managing
 liquidio adapter
Date: Sun, 30 Jul 2017 22:21:04 +0200
Message-ID: <20170730202103.GA8969@vergenet.net>
References: <20170729061707.GA1134@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35844 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754239AbdG3UVH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 16:21:07 -0400
Received: by mail-wm0-f47.google.com with SMTP id t201so163505822wmt.1
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 13:21:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170729061707.GA1134@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 11:17:07PM -0700, Felix Manlunas wrote:
> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> 
> The LiquidIO adapter has processor cores that can run Linux. This patch
> set adds support to create a virtual Ethernet interface on host to
> communicate with applications running on Linux in the LiquidIO adapter.
> The virtual Ethernet interface also provides login access to Linux on
> LiquidIO through ssh for management and debugging.

As per the somewhat more detailed feedback provided by my colleague Jakub
Kicinski to v1 of this patchset[1] I am concerned that this patchset breaks down
the long standing practice of not granting direct access to firmware from
userspace.

[1] https://www.spinics.net/lists/netdev/msg444929.html
