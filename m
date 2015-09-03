From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 1/1] net/ipv6: Correct PIM6 mrt_lock handling
Date: Wed, 2 Sep 2015 22:08:51 -0700
Message-ID: <CAHA+R7P8V1G-H5KB1p5hAE9hG3fa2_cdea1HB7rdA0QbN4gfJA@mail.gmail.com>
References: <1441245151-11495-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, James Morris <jmorris@namei.org>
To: Richard Laing <richard.laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:34014 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbbICFIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 01:08:51 -0400
Received: by ykdg206 with SMTP id g206so32715052ykd.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 22:08:51 -0700 (PDT)
In-Reply-To: <1441245151-11495-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 6:52 PM, Richard Laing
<richard.laing@alliedtelesis.co.nz> wrote:
> In the IPv6 multicast routing code the mrt_lock was not being released
> correctly in the MFC iterator, as a result adding or deleting a MIF would
> cause a hang because the mrt_lock could not be acquired.
>
> This fix is a copy of the code for the IPv4 case and ensures that the lock
> is released correctly.
>
> Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>

Good catch!

Acked-by: Cong Wang <cwang@twopensource.com>

Needs to go to -stable too.
