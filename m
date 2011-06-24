From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Thu, 23 Jun 2011 22:05:00 -0600
Message-ID: <BANLkTimXZvW16uMRGMeyH203e6MHxdNbSA@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
	<20110623183821.GA19188@S2100-06.ap.freescale.net>
	<BANLkTi=8Mks6T85WnEyihmB21U1j7reHrQ@mail.gmail.com>
	<20110624034859.GB19188@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110624034859.GB19188-+NayF8gZjK2ctlrPMvKcciBecyulp+rMXqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2011 at 9:49 PM, Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org> wrote:
> On Thu, Jun 23, 2011 at 05:11:54PM -0600, Grant Likely wrote:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int devid =3D get_alias_name_id(pp->name=
, devname);
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We do not want to proceed this sentin=
el one */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(pp->name, "name") && !strcmp=
(pp->value, "aliases"))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> Skipping the 'name' property is good, but I don't think you need to
>> check the value. =A0You should also skip the "phandle" property.
>>
> Ok. I have not seen "phandle" property in aliases node though. =A0Can
> you give me an example, so that I can make one up for testing?

It's a standard property that shows up automatically if any node
happens to have a phandle reference to another node.  The name will be
either "phandle" or "linux,phandle".  Search for "linux,phandle" in
drivers/of/fdt.c to see how that property is processed.

g.
