From: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Sat, 13 Apr 2013 15:00:37 -0400
Message-ID: <20130413190037.GY28693@titan.lakedaemon.net>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <20130411165303.GI28693@titan.lakedaemon.net>
 <20130413172126.6cca0809@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: moinejf-GANU6spQydw@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jogo-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org, Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130413172126.6cca0809@skate>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Sat, Apr 13, 2013 at 05:21:26PM +0200, Thomas Petazzoni wrote:
> Dear Jason Cooper,
> 
> On Thu, 11 Apr 2013 12:53:03 -0400, Jason Cooper wrote:
> 
> > With this and Thomas' pci series, we will have Kirkwood fully
> > converted to devicetree, can begin removing board files, and finally
> > begin migrating everything over to mach-mvebu/.  This will lead to
> > the removal of five directories under arch/arm/ (plat-orion,
> > mach-kirkwood, mach-orion5x, mach-dove, and mach-mv78xx0).
> 
> No, we can't remove mach-orion5x and mach-mv78xx0 for now, they have
> not been converted at all in terms of gpio/pinmux support. I've started
> writing some pinmux code for orion5x but it's not ready.
> 
> I don't think we should rush in doing this merge into mach-mvebu. I'd
> prefer to have the following conditions be met before a platform gets
> merged into mach-mvebu:
> 
>  * The mach-<foo> directory no longer depends on anything in
>    plat-orion. For mach-kirkwood, things are OK (for the DT platforms)
>    for GPIO, MPP and PCIe, but some work remains for the IRQ controller
>    driver and the timer driver.
> 
>  * All boards have been converted to the Device Tree. For
>    mach-kirkwood, we're getting closer.
> 
> Once a given mach-<foo> platform meets these conditions, it will be a
> clean platform, and we can merge it into mach-mvebu without any
> problem.
> 
> So let's continue the cleanup work, conversion to DT, usage of drivers
> in drivers/, improvement of pinmux to support orion5x/mv78xx0, and do
> the move per-platform, once they are ready.
> 
> What do you think?

I agree completely.  I was simply restating the longview goal of the
work we are doing (above and beyond adding armadaXP/370).  I probably
should have given a time reference for "This will lead to..." :)

Also, I have a feeling that not all legacy boards will get converted
over.  If there is no interest or no way to test, certains boards may
get deprecated.

thx,

Jason.
