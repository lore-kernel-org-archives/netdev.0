From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v6, 3/5] dt: move guts devicetree doc out of powerpc directory
Date: Fri, 25 Mar 2016 06:38:16 +0000
Message-ID: <HE1PR04MB08895D48A45AD3F6B32FB088F8830@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
	<1457518131-11339-4-git-send-email-yangbo.lu@nxp.com>
	<20160317170640.GB21009@rob-hp-laptop>
	<HE1PR0401MB1931444381E249E41C45C748918C0@HE1PR0401MB1931.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Zhao Qiang <qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jochen
	Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>, Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
To: Scott Wood <scott.wood-3arQi8VN3Tc@public.gmane.org>, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <HE1PR0401MB1931444381E249E41C45C748918C0-B0v07Ae2tarQP5LCsfKN8o3W/0Ik+aLCnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Scott Wood
> Sent: Saturday, March 19, 2016 2:16 AM
> To: Rob Herring; Yangbo Lu
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org;
> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; linux-
> clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> Russell King; Jochen Friedrich; Joerg Roedel; Claudiu Manoil;
> ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Bhupesh Sharma; Zhao Qiang; Kumar Gala; Santosh
> Shilimkar; Yang-Leo Li; Xiaobo Xie
> Subject: Re: [v6, 3/5] dt: move guts devicetree doc out of powerpc
> directory
> 
> On 03/17/2016 12:06 PM, Rob Herring wrote:
> > On Wed, Mar 09, 2016 at 06:08:49PM +0800, Yangbo Lu wrote:
> >> Move guts devicetree doc to
> >> Documentation/devicetree/bindings/soc/fsl/
> >> since it's used by not only PowerPC but also ARM. And add a
> >> specification for 'little-endian' property.
> >>
> >> Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
> >> ---
> >> Changes for v2:
> >> 	- None
> >> Changes for v3:
> >> 	- None
> >> Changes for v4:
> >> 	- Added this patch
> >> Changes for v5:
> >> 	- Modified the description for little-endian property Changes for
> >> v6:
> >> 	- None
> >> ---
> >>  Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt | 3
> >> +++
> >>  1 file changed, 3 insertions(+)
> >>  rename Documentation/devicetree/bindings/{powerpc =>
> >> soc}/fsl/guts.txt (91%)
> >>
> >> diff --git a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt
> >> b/Documentation/devicetree/bindings/soc/fsl/guts.txt
> >> similarity index 91%
> >> rename from Documentation/devicetree/bindings/powerpc/fsl/guts.txt
> >> rename to Documentation/devicetree/bindings/soc/fsl/guts.txt
> >> index b71b203..07adca9 100644
> >> --- a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt
> >> +++ b/Documentation/devicetree/bindings/soc/fsl/guts.txt
> >> @@ -25,6 +25,9 @@ Recommended properties:
> >>   - fsl,liodn-bits : Indicates the number of defined bits in the LIODN
> >>     registers, for those SOCs that have a PAMU device.
> >>
> >> + - little-endian : Indicates that the global utilities block is
> little
> >> +   endian. The default is big endian.
> >
> > The default is "the native endianness of the system". So absence on an
> > ARM system would be LE.
> 
> No.  For this binding, the default is big-endian, because that's what
> existed for this device before an endian property was added.
> 
> "endianness of the system" is not a well-defined concept.
> 
> > This property is valid for any simple-bus device,
> 
> Since when does simple-bus mean anything more than that the nodes
> underneath it can be used without bus-specific knowledge?
> 
> > so it isn't really required to document per device. You can, but your
> > description had better match the documented behaviour.
> 
> Documented where?
> 
> In fact, Documentation/devicetree/bindings/common-properties.txt
> explicitly says of the endian properties, "If a binding supports these
> properties, then the binding should also specify the default behavior if
> none of these properties are present."
> 
> -Scott

[Lu Yangbo-B47093] So, Rob, could you accept this patch after so much discussion?
:)
