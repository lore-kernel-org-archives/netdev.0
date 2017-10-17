From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 00/58] networking: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:44 -0700
Message-ID: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:55160 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757918AbdJQA3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 20:29:54 -0400
Received: by mail-pg0-f41.google.com with SMTP id l24so36554pgu.11
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 17:29:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the current set of outstanding networking patches to perform
conversions to the new timer interface (rebased to -next). This is not
all expected conversions, but it contains everything needed in networking
to eliminate init_timer(), and all the non-standard setup_*_timer() uses.

Thanks,

-Kees
