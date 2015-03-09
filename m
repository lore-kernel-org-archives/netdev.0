From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [E1000-devel] [PATCH v2 2/3] if_link: Add VF multicast promiscuous
 control
Date: Mon, 09 Mar 2015 00:27:14 -0700
Message-ID: <54FD4B52.6010100@gmail.com>
References: <CAJ3xEMjNKJFps7C2jsuFfnSn8pDtkCTtEhuQz8s+f=euR5=BXA@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	=?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMjNKJFps7C2jsuFfnSn8pDtkCTtEhuQz8s+f=euR5=BXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 03/08/2015 02:15 PM, Or Gerlitz wrote:
> On Mon, Feb 23, 2015 at 11:14 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> [...]
>> We discussed this during NetConf last week, and Don is correct that a
>> custom sysfs interface is not the way we want to handle this.  We agreed
>> upon a generic interface so that any NIC is able to turn on or off VF
>> multicast promiscuous mode.
> 
> Jeff, please make sure to either respond to my comments on the V2
> thread (or better) address them for the V3 post.
> 
> 
> http://marc.info/?l=linux-netdev&m=142441852518152&w=2
> http://marc.info/?l=linux-netdev&m=142441867218183&w=2

I agree with you that the patch descriptions should be cleaned up and
"beefed" up for that matter.

If/when I look to push his series of patches, I will make sure that your
concerns are addressed so that we can get a accurate changelog.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJU/UtSAAoJEOVv75VaS+3On0kP/3P+DkiCmset60z9Ms6MpqHZ
/J06eJpplGXz/TnKF1wTrOxgV+LV750q4J0IXkd/kbj23sC5SOnsxHlMWdb4SFWk
OW2vcB1HEqug7xCi9FukJzaORSfH1hWeSNtEuvKtjOREVLTCSZWkEyYE0SMJTU7N
ISaQtFlkOXomtZbri//M6XBVxW+DFyrEhjZgPl7HY+x2nZIXWh8NwI5kp7zYst2S
mWbNUIi8lJEHWbhF0MBG+QGSoND6zeKGJ5JWjp3ml40a4DNmAs4cVftsV7wvir8/
+QITHejBkIboZe8C7YrTNGN2qfzQfMsRRzdAaQW4Q4pr5MQcwAKEN/iHoG/jBik2
y00xJ6pf7v8ogNs72oJ24tFnp93H1nusIXG1oWVo+cwLwkDbGS0oLYs/5r6bMk+7
Z4JVieh0gcbeIFF7i3ZVOSKFcUVSFf5Kvw0isY7nnefyrhSJ1jQbP3i8ABVrH2fN
zO06JSARwu797r78292eXyGe74bE4LGmIHbwGKDP/Mz/1DP+Qafk+mEllQIxSFel
ODQSAjOQZTnP9KZ+t2XUdLnImlaKPnfjtMjdEny678/fmcZh1zjAHLTn4gmrA9vq
otKjWCS3cA6UVCyn+ph8+2sHtRLW6w7pQ7BcIXLTlaPp/gC97f3eHxvRN4nV1vA5
c+gQPJx98sCiBd3gFKX0
=9V5M
-----END PGP SIGNATURE-----
