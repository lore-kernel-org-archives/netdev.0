From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH] mwifiex: mask PCIe interrupts before removal
Date: Fri, 1 Jul 2016 10:42:40 -0700
Message-ID: <CAD=FV=W6BttCyg6Pq4hdBHaQ7hYXF0-ACHiqR84X4M4WG2ppVw@mail.gmail.com>
References: <1467325262-82799-1-git-send-email-briannorris@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Brian Norris <computersforpeace@gmail.com>,
	Stephen Barber <smbarber@chromium.org>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: Brian Norris <briannorris@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467325262-82799-1-git-send-email-briannorris@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jun 30, 2016 at 3:21 PM, Brian Norris <briannorris@chromium.org> wrote:
> The PCIe driver didn't mask the host interrupts before trying to tear
> down. This causes lockups at reboot or rmmod when using MSI-X on 8997,
> since the MSI handler gets confused and locks up the system.
>
> Also tested on 8897, which does not support MSI-X (and wasn't
> experiencing this same bug). No regressions seen there.
>
> Signed-off-by: Brian Norris <briannorris@chromium.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/pcie.c | 6 ++++++
>  1 file changed, 6 insertions(+)

This looks very sane but isn't my area of expertise at all.  However,
if my Reviewed-by is at all useful feel free to add it.  I will say
that this fixes the issue of the crash at reboot time, so at least
I'll add:

Tested-by: Douglas Anderson <dianders@chromium.org>
