From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 3/6] dt: booting-without-of: DT fix s/#interrupt-cell/#interrupt-cells/
Date: Wed, 30 Aug 2017 19:20:39 +1000
Message-ID: <87wp5l1kew.fsf@concordia.ellerman.id.au>
References: <1496407129-13527-1-git-send-email-geert+renesas@glider.be> <1496407129-13527-4-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        dri-devel@lists.freedesktop.org, linux-amlogic@lists.infradead.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        David Airlie <airlied@linux.ie>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Chanho Min <chanho.min@lge.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496407129-13527-4-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert+renesas@glider.be> writes:

> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Acked-by: Rob Herring <robh@kernel.org>
> ---

Rob this has your ack, but I'd expect it to go via your tree? Or should
I grab it?

cheers

> diff --git a/Documentation/devicetree/booting-without-of.txt b/Documentation/devicetree/booting-without-of.txt
> index 280d283304bb82d8..f35d3adacb987f7d 100644
> --- a/Documentation/devicetree/booting-without-of.txt
> +++ b/Documentation/devicetree/booting-without-of.txt
> @@ -1309,7 +1309,7 @@ number and level/sense information. All interrupt children in an
>  OpenPIC interrupt domain use 2 cells per interrupt in their interrupts
>  property.
>  
> -The PCI bus binding specifies a #interrupt-cell value of 1 to encode
> +The PCI bus binding specifies a #interrupt-cells value of 1 to encode
>  which interrupt pin (INTA,INTB,INTC,INTD) is used.
>  
>  2) interrupt-parent property
> -- 
> 2.7.4
