From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net/mlx4_core: Fix unaligned accesses
Date: Thu, 30 Apr 2015 16:26:42 +0300
Message-ID: <CAJ3xEMhrSDXhGgQbV=EGJ_TcJfJE3=44Ad_daKmDpcQwnuxkpg@mail.gmail.com>
References: <1430340771-12425-1-git-send-email-david.ahern@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Ahern <david.ahern@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35834 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbD3N0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 09:26:43 -0400
Received: by oign205 with SMTP id n205so47561741oig.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 06:26:42 -0700 (PDT)
In-Reply-To: <1430340771-12425-1-git-send-email-david.ahern@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 11:52 PM, David Ahern <david.ahern@oracle.com> wrote:
> Addresses the following kernel logs seen during boot:
>
> Kernel unaligned access at TPC[100ee150] mlx4_QUERY_HCA+0x80/0x248 [mlx4_core]
> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
> Kernel unaligned access at TPC[100f071c] mlx4_QUERY_ADAPTER+0x100/0x12c [mlx4_core]
>
> Signed-off-by: David Ahern <david.ahern@oracle.com>

Looks OK

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
