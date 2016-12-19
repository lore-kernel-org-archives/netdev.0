From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO
 voltage
Date: Mon, 19 Dec 2016 16:35:04 -0600
Message-ID: <20161219223504.ttwayzpfvdumgouu@rob-hp-laptop>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
 <1481841044-4314-2-git-send-email-glansberry@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, lauro.venancio@openbossa.org,
        aloisio.almeida@openbossa.org, sameo@linux.intel.com,
        mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        mgreer@animalcreek.com, justin@kuvee.com
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481841044-4314-2-git-send-email-glansberry@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 05:30:43PM -0500, Geoff Lansberry wrote:
> From: Geoff Lansberry <geoff@kuvee.com>
> 
> ---
>  Documentation/devicetree/bindings/net/nfc/trf7970a.txt |  2 ++
>  drivers/nfc/trf7970a.c                                 | 13 ++++++++++++-
>  2 files changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> index 9dda879..208f045 100644
> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> @@ -21,6 +21,7 @@ Optional SoC Specific Properties:
>  - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
>    where an extra byte is returned by Read Multiple Block commands issued
>    to Type 5 tags.
> +- vdd_io_1v8: Set to specify that the trf7970a io voltage should be set to 1.8V

Use the regulator binding and provide a fixed 1.8V supply.

>  - crystal_27mhz: Set to specify that the input frequency to the trf7970a is 27.12MHz
>  
>  
> @@ -45,6 +46,7 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>  		irq-status-read-quirk;
>  		en2-rf-quirk;
>  		t5t-rmb-extra-byte-quirk;
> +		vdd_io_1v8;
>  		crystal_27mhz;
>  		status = "okay";
>  	};
