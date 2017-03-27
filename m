From: Rob Herring <robh+dt@kernel.org>
Subject: Re: [PATCH RFC v4 10/10] tty: serdev: add functions to retrieve
 common UART settings
Date: Mon, 27 Mar 2017 15:00:00 -0500
Message-ID: <CAL_JsqJ3b2zTGNHNVtt6Y+k23iw+2G2z-Jm2786a8CEzZBS7=g@mail.gmail.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com> <1490621848-24828-11-git-send-email-stefan.wahren@i2se.com>
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
Received: from mail.kernel.org ([198.145.29.136]:33492 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751183AbdC0UA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 16:00:29 -0400
In-Reply-To: <1490621848-24828-11-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 8:37 AM, Stefan Wahren <stefan.wahren@i2se.com> wrote:
> Currently serdev core doesn't provide functions to retrieve common
> UART settings like data bits, stop bits or parity. This patch adds
> the interface to the core and the necessary implementation for
> serdev-ttyport.

It doesn't provide them because why do you need to know? The attached
device should request the settings it needs and be done with it. Maybe
some devices can support a number of settings and you could want
negotiate the settings with the UART, though surely 8N1 is in that
list. It's rare to see something that's not 8N1 from what I've seen.

Rob
