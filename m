From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net/mlx4: Handle return codes in mlx4_qp_attach_common
Date: Sun, 27 Sep 2015 07:31:39 +0300
Message-ID: <CAJ3xEMjqa76nvMXYEGr1g3qPNkiQnP99AXNpkyAchE_+V=vx-A@mail.gmail.com>
References: <CAM5t4r_uaRPJT0kiaqNkygu1ciCoVSVQhj5MLkn69uieXx1MHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Robb Manes <rmanes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35268 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbI0Ebk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 00:31:40 -0400
Received: by igbkq10 with SMTP id kq10so33665120igb.0
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 21:31:39 -0700 (PDT)
In-Reply-To: <CAM5t4r_uaRPJT0kiaqNkygu1ciCoVSVQhj5MLkn69uieXx1MHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 5:39 PM, Robb Manes <rmanes@redhat.com> wrote:
> Both new_steering_entry() and existing_steering_entry() return values
> based on their success or failure, but currently they fall through
> silently.  This can make troubleshooting difficult, as we were unable
> to tell which one of these two functions returned errors or
> specifically what code was returned.  This patch remedies that
> situation by passing the return codes to err, which is returned by
> mlx4_qp_attach_common() itself.
>
> This also addresses a leak in the call to mlx4_bitmap_free() as well.
>
> Signed-off-by: Robb Manes <rmanes@redhat.com>

looks correct.

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
