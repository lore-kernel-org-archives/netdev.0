From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Mon, 14 Sep 2015 18:11:09 +0100
Message-ID: <20150914171109.GW12027@sirena.org.uk>
References: <81516fb9c662cc338b5af5b63fbbcde5374e0893.1442202447.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4492793628393361331=="
Cc: "open list:NETWORKING DRIVERS \(WIRELESS\)"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..."
	<alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>, Avri Altman <avri.altman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"open list:DOCUMENTATION" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
	"open list:MEMORY MANAGEMENT" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Luciano Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wang Long <long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Richard Fitzgerald <rf-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Johan Hedberg <johan.hedberg@g
To: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <81516fb9c662cc338b5af5b63fbbcde5374e0893.1442202447.git.viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
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


--===============4492793628393361331==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gABkrxlT8b359YXV"
Content-Disposition: inline


--gABkrxlT8b359YXV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 14, 2015 at 09:21:54AM +0530, Viresh Kumar wrote:
> Long back 'bool' type used to be a typecast to 'int', but that changed
> in v2.6.19. And that is a typecast to _Bool now, which (mostly) takes
> just a byte. Anyway, the bool type is implementation defined, and better
> we don't assume its size to be 4 bytes or 1.

Acked-by: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

--gABkrxlT8b359YXV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJV9v+sAAoJECTWi3JdVIfQjVwH/jgfnm1aCRP2kYvsvOpD6Rhn
kzv9ftGGPrLduAP9ROoaVhjxQkuM2GeRIumTyi3MqALAowWUGrIZq4NsNEJCrS7i
hMEXqTeR55u5D1BPXElYtftTImYZDDvfrEjs/3cGvAN/FObbWA6q1a95DTEYw7Qw
w1G2AXM+1fenUoqF/9sNbAfjUkjV5Mm3cF1SWuYc+q656/Iuzzhj6foZECAVqf9o
VVqePsqpfnD/LFsU5GKYS42AcaFyn3deAhRB+IbLWKOOwuiCWrgLisYWH2VnsyiI
BATL4sO2gk7mvpJOQXpQiCNDw+h08FiWoLscnN+UbvDhs7TJrdUAjYWLioFZJhw=
=s8m4
-----END PGP SIGNATURE-----

--gABkrxlT8b359YXV--

--===============4492793628393361331==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============4492793628393361331==--
