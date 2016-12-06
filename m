From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] ASoC: atmel: tse850: rely on the ssc to register as
 a cpu dai by itself
Date: Tue, 6 Dec 2016 09:52:07 -0600
Message-ID: <20161206155207.jmybycruwsyplabr@rob-hp-laptop>
References: <1480593549-6464-1-git-send-email-peda@axentia.se>
 <1480593549-6464-3-git-send-email-peda@axentia.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Liam Girdwood <lgirdwood-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
        Takashi Iwai <tiwai-IBi9RG/b67k@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1480593549-6464-3-git-send-email-peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2016 at 12:59:09PM +0100, Peter Rosin wrote:
> Signed-off-by: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
> ---
>  .../bindings/sound/axentia,tse850-pcm5142.txt      |  5 ++---
>  sound/soc/atmel/tse850-pcm5142.c                   | 23 +++-------------------
>  2 files changed, 5 insertions(+), 23 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt b/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt
> index 5b9b38f578bb..fd12ecb35b5c 100644
> --- a/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt
> +++ b/Documentation/devicetree/bindings/sound/axentia,tse850-pcm5142.txt
> @@ -2,8 +2,7 @@ Devicetree bindings for the Axentia TSE-850 audio complex
>  
>  Required properties:
>    - compatible: "axentia,tse850-pcm5142"
> -  - axentia,ssc-controller: The phandle of the atmel SSC controller used as
> -    cpu dai.
> +  - axentia,cpu-dai: The phandle of the cpu dai.

You are breaking backwards compatibility with old DTBs. You either need 
to not do that or explain in the commit why that is okay.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
