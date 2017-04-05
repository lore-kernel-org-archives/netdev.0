From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH v3 1/3] NFC: trf7970a: add device tree option for 27MHz
 clock
Date: Wed, 5 Apr 2017 11:06:11 +0200
Message-ID: <20170405090611.GF2136@zurbaran.ger.intel.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, robh+dt@kernel.org,
        mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        mgreer@animalcreek.com, justin@kuvee.com
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geoff,

On Wed, Dec 21, 2016 at 11:18:32PM -0500, Geoff Lansberry wrote:
> The TRF7970A has configuration options to support hardware designs
> which use a 27.12MHz clock. This commit adds a device tree option
> 'clock-frequency' to support configuring the this chip for default
> 13.56MHz clock or the optional 27.12MHz clock.
> 
> Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
> ---
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  2 +
>  drivers/nfc/trf7970a.c                             | 50 +++++++++++++++++-----
>  2 files changed, 41 insertions(+), 11 deletions(-)
Patches #1 and #2 applied to nfc-next. I'll wait for you to rework #3
before merging.

Cheers,
Samuel.
