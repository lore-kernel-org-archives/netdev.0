From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: fix stats locking in e1000_watchdog_task
Date: Mon, 4 Apr 2011 01:32:23 -0700
Message-ID: <BANLkTinBLnZ3j5dLD4+Ze+pPuqY+OFgZZg@mail.gmail.com>
References: <1301681764-25315-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51876 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848Ab1DDIcZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 04:32:25 -0400
Received: by fxm17 with SMTP id 17so3725681fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 01:32:24 -0700 (PDT)
In-Reply-To: <1301681764-25315-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2011 at 11:16, Flavio Leitner <fleitner@redhat.com> wrot=
e:
> Just move the unlock down a bit because it unlocks too
> early leaving a chance for get_stats64() run in parallel
> while it is still accessing the stats.
>
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>

Thanks!  I have added this to my e1000e queue of patches.

--=20
Cheers,
Jeff
