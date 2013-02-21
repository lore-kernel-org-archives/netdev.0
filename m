From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: [PATCHv2 vringh 1/3] remoteproc: Add support for vringh (Host
	vrings)
Date: Thu, 21 Feb 2013 19:55:13 +0200
Message-ID: <CAK=Wgbam=Y5GJQxg2DSt2yR6CdcDxjZ5k_Av_0H8+6m+scN+Yw@mail.gmail.com>
References: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com>
	<1360669793-6921-2-git-send-email-sjur.brandeland@stericsson.com>
	<CAK=Wgbb0EeiCh504jsoX+izzi+ZogfEDttz2cHRd4pVXvQunQw@mail.gmail.com>
	<CAJK669bDu3SphxmEtA+h+v=btsN91t0S9Mn6ik-OKr=8gtducw@mail.gmail.com>
	<CAK=Wgba5XkK3c7qh1tYHMGEe7-Qima96uYO4E+uAPcaB8K6bmQ@mail.gmail.com>
	<CAJK669YHwR=nf2zSQR6buaA-x1JSowJfU16hkz1+N_WLL0qA+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>, netdev@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>, Ido Yariv <ido@wizery.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjurbren@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJK669YHwR=nf2zSQR6buaA-x1JSowJfU16hkz1+N_WLL0qA+A@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Sjur,

On Thu, Feb 21, 2013 at 7:28 PM, Sjur Br=E6ndeland <sjurbren@gmail.com> wro=
te:
> The motivation for using vringh was to avoid copying buffers
> when sending data from the modem to the host.

I may be missing something here, but why do you need vringh for that?

With rpmsg (which uses two regular vrings) both ends send huge amount
of data without copying it - we just send the pointers across.

Thanks,
Ohad.
