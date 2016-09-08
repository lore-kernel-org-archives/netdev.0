From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH V3] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Thu, 8 Sep 2016 11:49:31 -0600
Message-ID: <038d710a-f8fe-b569-11ee-2dc4c3ec6d28@wwwdotorg.org>
References: <20160901190216.5643-1-swarren@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160901190216.5643-1-swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/01/2016 01:02 PM, Stephen Warren wrote:
> From: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>
> The Synopsys DWC EQoS is a configurable IP block which supports multiple
> options for bus type, clocking and reset structure, and feature list.
> Extend the DT binding to define a "compatible value" for the configuration
> contained in NVIDIA's Tegra186 SoC, and define some new properties and
> list property entries required by that configuration.
>
> Signed-off-by: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> ---
> v3:
> * Document legacy clock-names entries separately, and make it obvious
>   they're deprecated.
> * Reword the description of the "rx" clock to better describe the HW.
> * Add some extra guidance for future extensions of the binding to cover
>   configurations where additional RX clocks are required.
> * Explicitly document the list of clocks and resets for every compatible
>   value; don't miss any out.

Rob, Mark,

Does this version look good (Lars already acked it)? If so, if you could 
ack it that'd be great; I want to send some U-Boot drivers that use this 
binding, but don't want to do so before I know it's final.

Thanks.
