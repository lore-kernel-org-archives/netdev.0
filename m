From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Mon, 15 Aug 2016 17:59:57 +0000
Message-ID: <197F6532-FC5E-4D72-976D-4207BAD8D83E@intel.com>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
 <1452684335-46107-4-git-send-email-hare@suse.de>
 <20160209210458.GB32530@localhost>
 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
 <1470787409.3015.81.camel@kernel.crashing.org>
 <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
 <1470873296.3015.117.camel@kernel.crashing.org>
 <CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
 <20160811141700.4f4faabb@t450s.home>
 <1470978669.3015.155.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_0B97A36D-9514-48B6-9725-293733669A1D";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Alex Williamson <alex.williamson@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>,
	"Bjorn Helgaas" <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	"santosh@chelsio.com" <santosh@chelsio.com>,
	Netdev <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1470978669.3015.155.camel@kernel.crashing.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_0B97A36D-9514-48B6-9725-293733669A1D
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> We may want some kind of "strict" vs. "relaxed" model here to
> differenciate the desktop user wanting to give a function to his/her
> windows partition and doesn't care about strict isolation vs. the cloud
> data center.

I don't think desktop users appreciate hangs any more than anyone else, and  
that is one of the symptoms that can arise here without the vfio  
coordination.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_0B97A36D-9514-48B6-9725-293733669A1D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJXsgMdAAoJEDwO/+eO4+5uYqEP/10CAPxkFeUIud2v+pS5ZJE2
UKxBzqRgql3GqA6hxm+RbtvRXIp1DhHO1YuGVkdTobjS8dlTEwr9rLIRmoz099fN
411HU3MupMsJ2bsag+RI/XNKBbqqteZ8vtLMMj8Ep72TDnxsSLvkgOTtaI03StoQ
ytvErumSPmO8xIQJFjogbjiGbxCO233KW8vH8tWzbnbcABSYU7ohNjkhJfxSKCSY
Wl7Q4nCGqKtwzSnSaogix8MSuPqT4YdAbFfrKXFlh8n1wF4VLuKpZC04/HWJwdFk
XuedPkQ3o7ukbgwVXGCK3uIDBmhBJUGkJl2vwCG5mJaUqYTQPUxrTGuWHhBi4SqK
cUg2wanWva7ziU4zzMf1ZZw4mhj/oCYucOFAaPNIf/uvkDfNfIKyYiAGT+ktFOLW
MTTdrfAb8C0i7i+whhFNPDkYl9MI+XRXWaPS1wK6SZF3hsJHZn4CSi6YG7MKWxET
n0Zu6vT2iLQUqX6pQ2iab4bdaJQ7boKAs/DY270FAPWsFMIASkmJNcd2+tKmLkPn
1n/GhXcW66QiiweqgFO4W1QhclpEiV7ry6Jd4WmbKlZDTOET6DoMd9KeEla0Ainx
bzb7c/ob4DKw0W+sAi5bRxdLcayNWw+OHaeeoMTuPXl2wujyDvqUhTBmhok61Hy/
/x4xcsjMGxD92kwRRDgk
=uz2d
-----END PGP SIGNATURE-----

--Apple-Mail=_0B97A36D-9514-48B6-9725-293733669A1D--
