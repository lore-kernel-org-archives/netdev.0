From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH linux-next] dmaengine: add context
	parameter fixups
Date: Mon, 26 Mar 2012 12:01:49 +0100
Message-ID: <20120326110149.GL3098@opensource.wolfsonmicro.com>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	<CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
	<1332740082.19804.15.camel@vkoul-udesk3>
	<20120326094200.GA3098@opensource.wolfsonmicro.com>
	<1332755670.19804.91.camel@vkoul-udesk3>
	<20120326103354.GD3098@opensource.wolfsonmicro.com>
	<1332758906.19804.97.camel@vkoul-udesk3>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2783375559176030536=="
Cc: fabio.estevam@freescale.com, alsa-devel@alsa-project.org, samuel@sortiz.org,
	paul.gortmaker@windriver.com, tiwai@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	linux-next@vger.kernel.org, dan.j.williams@intel.com,
	Fabio Estevam <festevam@gmail.com>, lrg@ti.com
To: Vinod Koul <vinod.koul@linux.intel.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <1332758906.19804.97.camel@vkoul-udesk3>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org


--===============2783375559176030536==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gwtGiOGliFx8mAnm"
Content-Disposition: inline


--gwtGiOGliFx8mAnm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 26, 2012 at 04:18:26PM +0530, Vinod Koul wrote:

> But we don't want the clients to use this additional parameter or be
> exposed to it if not required. Every client is expected to use the
> dmaengine wrappers for prepare and not invoke .device_ callbacks.

Are those wrappers present in what's gone to Linus' tree, and can
someone please send a patch to convert to using them?

--gwtGiOGliFx8mAnm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPcEyPAAoJEBus8iNuMP3dm3EP/3oRKL1MVbrQkzaWbv/qdl5t
xsVECi+gMJJOfLF8VFVQrgWkF9Wov9CVUWd3FovsHsEf16tdiLi4CqxgVC9fXxN6
Sh9K4S47acJpPZufG3FUYgib+94PlgjfG1PFDApK9mBmDagVPODNdXuyZpVqK2hO
102aDt95xuC+qq1Z+ERn+nO0RrAwRLK2Zl9PWToSUPHkJBEeSQqXlgbPIFzqijpG
cWlCRbAf2fn+Y3tiGo4jpw63coSqPknZUNtkHMhuxBU/+euAZf+fZaIlPoeWJJ0d
kY6T57XQJ9m4DcUSYccVSAkgw1pJ1uPqE7+rBeIQfp5AfXbLtNR60BT+SCZ4fzuY
rA8jDF+NbBweLZf6dyq9a3LKI08MMeclkf10XRA4jMvGFbIGDJ34DWYZgmKur8Zb
HSDLfBEsOteJahe8z5rH+fU19mbD4yIJbV7QbzlMOOgVX4fT3TQc0fy8SbBFvbZZ
6M5ZHH3UA7qwfyCURmcBlHQT7767euDpSkxbTXfZQsebsOZFRevZDn/LitHQovB4
1K4Vuo/HYCsW99G8wEKGbga082xk4RwatYz0nCmbAxNScqfPMYP0r4AAfB9XGljA
hEvmMY56sM/3fRHl9ZNJJ9oZP63oMAIre/U+j/o/l715Y3V607iGLPDt/0NNKLwN
l3vYf83ze8bsUISQrfj2
=Y5p1
-----END PGP SIGNATURE-----

--gwtGiOGliFx8mAnm--

--===============2783375559176030536==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2783375559176030536==--
