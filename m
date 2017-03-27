From: Rob Herring <robh+dt@kernel.org>
Subject: Re: [PATCH RFC v4 09/10] tty: serdev-ttyport: return actual baudrate
 from ttyport_set_baudrate
Date: Mon, 27 Mar 2017 14:50:28 -0500
Message-ID: <CAL_JsqJcyRG-am_XjZ2W_oJS0HAshD4nPcX4s--j7XBbUU+-Og@mail.gmail.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com> <1490621848-24828-10-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33600 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751716AbdC0UCA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 16:02:00 -0400
In-Reply-To: <1490621848-24828-10-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 8:37 AM, Stefan Wahren <stefan.wahren@i2se.com> wrote:
> Instead of returning the requested baudrate, we better return the
> actual one because it isn't always the same.
>
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  drivers/tty/serdev/serdev-ttyport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
