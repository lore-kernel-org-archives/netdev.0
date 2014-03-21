From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v4] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Fri, 21 Mar 2014 19:12:43 +0000
Message-ID: <84837c9e73f24bcd8f652a24f616ff1e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1395354521-12632-1-git-send-email-haiyangz@microsoft.com>
	<20140321.144957.550032279989990583.davem@davemloft.net>
 <20140321.145501.2003616654661701935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140321.145501.2003616654661701935.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, March 21, 2014 2:55 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v4] hyperv: Add support for virtual Rece=
ive
> Side Scaling (vRSS)
>=20
> From: David Miller <davem@davemloft.net>
> Date: Fri, 21 Mar 2014 14:49:57 -0400 (EDT)
>=20
> > From: Haiyang Zhang <haiyangz@microsoft.com>
> > Date: Thu, 20 Mar 2014 15:28:41 -0700
> >
> >> This feature allows multiple channels to be used by each virtual N=
IC.
> >> It is available on Hyper-V host 2012 R2.
> >>
> >> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> >> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> >
> > Applied, thanks.
>=20
> Actually I had to revert, this doesn't even compile.
>=20
> drivers/net/hyperv/netvsc.c: In function =A1netvsc_channel_cb=A2:
> drivers/net/hyperv/netvsc.c:891:2: error: implicit declaration of
> function =A1get_per_channel_state=A2 [-Werror=3Dimplicit-function-dec=
laration]
> drivers/net/hyperv/netvsc.c:891:9: warning: assignment makes pointer
> from integer without a cast [enabled by default]
> drivers/net/hyperv/netvsc.c: In function =A1netvsc_device_add=A2:
> drivers/net/hyperv/netvsc.c:998:2: error: implicit declaration of
> function =A1set_per_channel_state=A2 [-Werror=3Dimplicit-function-dec=
laration]
> cc1: some warnings being treated as errors
> make[3]: *** [drivers/net/hyperv/netvsc.o] Error 1
> make[3]: *** Waiting for unfinished jobs....
> drivers/net/hyperv/rndis_filter.c: In function =A1netvsc_sc_open=A2:
> drivers/net/hyperv/rndis_filter.c:988:2: error: implicit declaration =
of
> function =A1set_per_channel_state=A2 [-Werror=3Dimplicit-function-dec=
laration]
> cc1: some warnings being treated as errors
> make[3]: *** [drivers/net/hyperv/rndis_filter.o] Error 1
> make[2]: *** [drivers/net/hyperv] Error 2
> make[2]: *** Waiting for unfinished jobs....
> make[1]: *** [drivers/net] Error 2
> make[1]: *** Waiting for unfinished jobs....
> make: *** [drivers] Error 2

The per channel state variable and functions are defined by this patch,
which has been applied on 2/07:
Drivers: hv: vmbus: Support per-channel driver state
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/=
?id=3D8a7206a89f85c8439561b0eff85bb9440a2e97a9

Could it be merged into net-next tree?

Thanks,
- Haiyang
