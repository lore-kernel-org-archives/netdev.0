From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH V4] r8152: add Linksys USB3GIGV1 id
Date: Thu, 28 Sep 2017 16:57:09 -0700
Message-ID: <CAD=FV=Wft5UZ0oPP9e3uZFJ3PxY2YKKbSQiEALOBp-Kfd0rM2w@mail.gmail.com>
References: <20170928183500.61199-1-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>,
        linux-usb <linux-usb@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928183500.61199-1-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant,

On Thu, Sep 28, 2017 at 11:35 AM, Grant Grundler <grundler@chromium.org> wrote:
> This linksys dongle by default comes up in cdc_ether mode.
> This patch allows r8152 to claim the device:
>    Bus 002 Device 002: ID 13b1:0041 Linksys
>
> Signed-off-by: Grant Grundler <grundler@chromium.org>
> ---
>  drivers/net/usb/cdc_ether.c | 10 ++++++++++
>  drivers/net/usb/r8152.c     |  2 ++
>  2 files changed, 12 insertions(+)

This seems nice to me now.  Thanks for all the fixes!  I'm no expert
in this area, but as far as I know this is ready to go now, so FWIW:

Reviewed-by: Douglas Anderson <dianders@chromium.org>
