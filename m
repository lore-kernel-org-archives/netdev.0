From: Rajkumar Manoharan <rmanohar@qti.qualcomm.com>
Subject: Re: [ath9k-devel] randconfig build error with next-20140519, in
 drivers/net/wireless/ath/ath9k/dfs.c
Date: Wed, 21 May 2014 16:31:45 +0530
Message-ID: <20140521110143.GA2375@qca.qualcomm.com>
References: <CA+r1ZhiM7EK08Y4kriXMugMc1Mbj5VDUPwKMq8-_k8Q8qhwPtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linville <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	<ath9k-devel@lists.ath9k.org>, netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+r1ZhiM7EK08Y4kriXMugMc1Mbj5VDUPwKMq8-_k8Q8qhwPtw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 19, 2014 at 09:31:16AM -0700, Jim Davis wrote:
> Building with the attached random configuration file,
>=20
> In file included from drivers/net/wireless/ath/ath9k/eeprom.h:22:0,
>                  from drivers/net/wireless/ath/ath9k/hw.h:27,
>                  from drivers/net/wireless/ath/ath9k/dfs.c:18:
> drivers/net/wireless/ath/ath9k/dfs.c: In function =E2=80=98ath9k_dfs_=
process_phyerr=E2=80=99:
> drivers/net/wireless/ath/ath9k/dfs.c:185:14: error: =E2=80=98struct a=
th_softc=E2=80=99
> has no member named =E2=80=98debug=E2=80=99
>     pe.ts - sc->debug.stats.dfs_stats.last_ts);
>               ^
> drivers/net/wireless/ath/ath9k/../ath.h:273:41: note: in definition o=
f
> macro =E2=80=98ath_dbg=E2=80=99
>    ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__); \
>                                          ^
> drivers/net/wireless/ath/ath9k/dfs.c:186:5: error: =E2=80=98struct at=
h_softc=E2=80=99
> has no member named =E2=80=98debug=E2=80=99
>    sc->debug.stats.dfs_stats.last_ts =3D pe.ts;
>      ^
> make[5]: *** [drivers/net/wireless/ath/ath9k/dfs.o] Error 1

Please select CONFIG_ATH9K_DEBUGFS.

-Rajkumar
