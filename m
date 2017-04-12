From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2 3/4] bluetooth: hci_uart: add LL protocol serdev driver
 support
Date: Wed, 12 Apr 2017 22:20:26 +0200
Message-ID: <1EF987AA-8426-43BF-B92B-62AFF554FAA1@holtmann.org>
References: <20170407143516.9945-1-robh@kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-bluetooth@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Wei Xu <xuwei5@hisilicon.com>, Eyal Reizer <eyalr@ti.com>,
        Satish Patel <satish.patel@linaro.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:51008 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755380AbdDLUU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 16:20:27 -0400
In-Reply-To: <20170407143516.9945-1-robh@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

> Turns out that the LL protocol and the TI-ST are the same thing AFAICT.
> The TI-ST adds firmware loading, GPIO control, and shared access for
> NFC, FM radio, etc. For now, we're only implementing what is needed for
> BT. This mirrors other drivers like BCM and Intel, but uses the new
> serdev bus.
> 
> The firmware loading is greatly simplified by using existing
> infrastructure to send commands. It may be a bit slower than the
> original code using synchronous functions, but the real bottleneck is
> likely doing firmware load at 115.2kbps.
> 
> Signed-off-by: Rob Herring <robh@kernel.org>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Gustavo Padovan <gustavo@padovan.org>
> Cc: Johan Hedberg <johan.hedberg@gmail.com>
> Cc: linux-bluetooth@vger.kernel.org
> ---
> v2:
> - Use IS_ENABLED() to fix module build
> 
> drivers/bluetooth/hci_ll.c | 261 ++++++++++++++++++++++++++++++++++++++++++++-
> 1 file changed, 260 insertions(+), 1 deletion(-)

can you re-send any missing patch on top of today's bluetooth-next tree.

Regards

Marcel
