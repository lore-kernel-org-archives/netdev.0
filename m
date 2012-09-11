From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Tue, 11 Sep 2012 16:03:31 +1000
Message-ID: <1347343411.2603.42.camel@pasglop>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
 <5028D040.60604@codethink.co.uk> <502D201E.9030304@codethink.co.uk>
 <201209101422.13875.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org, dale-1viX+2+OPRFcxvNqPlePQg@public.gmane.org,
 Ian Molton <ian.molton-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <201209101422.13875.arnd-r2nGTMty4D4@public.gmane.org>
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

On Mon, 2012-09-10 at 14:22 +0000, Arnd Bergmann wrote:
> Following up on the old discussion, I talked briefly about this
> issue with BenH at the kernel summit. The outcome basically is that
> it's a bit sad to have incompatible bindings, but it's not the end
> of the world,and it's more important to do it right this time.
> 
> Just make sure that you use different values for the 'compatible'
> strings and then do what you need to get the ARM hardware working.
> 
> Ideally, the new binding should be written in a way that powerpc
> machines can use the same one, but the existing ones all use
> an version of Open Firmware that is not going to get updated
> and it's also not too likely that we are going to see new
> powerpc machines based on this chip.

Right, mostly these machines where the Pegasos. Those came with a fairly
busted variant of Open Firmware which generated a pretty gross
device-tree.

For some reason, the manufacturer of those things was never willing to
fix anything in their firmware (despite the distributor providing
patches etc...), seemingly on the assumption that whatever they were
doing was perfect and operating system people like us didn't matter one
little bit :-)

So I don't care much about it. It would be nice to keep them working
since people in the community still have them but if it goes through
some "compat" code that detects old/broken device-trees and eventually
disappears when we finally drop support, then so be it.

Cheers,
Ben.
