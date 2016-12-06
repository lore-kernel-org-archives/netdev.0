From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Tue, 6 Dec 2016 14:45:09 -0800
Message-ID: <20161206144509.5365a623@xeon-e3>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35791 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbcLFWpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 17:45:17 -0500
Received: by mail-pf0-f179.google.com with SMTP id i88so72409870pfk.2
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 14:45:17 -0800 (PST)
In-Reply-To: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Dec 2016 00:33:08 +0200
Saeed Mahameed <saeedm@mellanox.com> wrote:

> This simple ethool change will give HW vendors the flexibility to set
> pure HW configurations (not directly related to netdev resources states
> and rings), without the need of vendor proprietary tools and hacks.


The danger is you need to restrict the kernel to only allow setting
safe registers (and this is HW dependent).  There are cases like secure
boot where it is expected that even root is not allowed to modify
all memory.

Also supporting closed format of device registers is not in the interest
of promoting open source.

I am not saying I fundamentally disagree with supporting this, but it
is a bigger step than you make it out to be.
