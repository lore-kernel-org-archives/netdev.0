From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 31/58] isdn/gigaset: Use kzalloc instead of open-coded
 field zeroing
Date: Thu, 19 Oct 2017 22:46:31 +0200
Message-ID: <1508445991.2274.1.camel@tiscali.nl>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
         <1508200182-104605-32-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud8.xs4all.net ([194.109.24.25]:42255 "EHLO
        lb2-smtp-cloud8.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752036AbdJSUqh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 16:46:37 -0400
In-Reply-To: <1508200182-104605-32-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-16 at 17:29 -0700, Kees Cook wrote:
> This replaces a kmalloc followed by a bunch of per-field zeroing with a
> single kzalloc call, reducing the lines of code.

Acked-by: Paul Bolle <pebolle@tiscali.nl>

Thanks,


Paul Bolle
