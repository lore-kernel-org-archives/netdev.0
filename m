From: Zefir Kurtisi <zefir.kurtisi-ASv44eHyqLVBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [ath9k-devel] randconfig build error with next-20140519, in drivers/net/wireless/ath/ath9k/dfs.c
Date: Wed, 21 May 2014 15:55:50 +0200
Message-ID: <537CB066.1070803@neratec.com>
References: <CA+r1ZhiM7EK08Y4kriXMugMc1Mbj5VDUPwKMq8-_k8Q8qhwPtw@mail.gmail.com> <20140521110143.GA2375@qca.qualcomm.com> <CAGRGNgXuS-ksFBAtmo8nLAPqPFKo2gHGDCsTcranU-k2-K3rfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Davis <jim.epost-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	linux-next <linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rajkumar Manoharan <rmanohar-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGRGNgXuS-ksFBAtmo8nLAPqPFKo2gHGDCsTcranU-k2-K3rfg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

sorry, I posted a related patch today ('[PATCH] ath9k: fix build error =
with
disabled debug'), but seems did not manage to set the correct in-reply-=
to field.


On 05/21/2014 02:12 PM, Julian Calaby wrote:
> Hi Rajkumar,
>=20
> On Wed, May 21, 2014 at 9:01 PM, Rajkumar Manoharan
> <rmanohar-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org> wrote:
>> On Mon, May 19, 2014 at 09:31:16AM -0700, Jim Davis wrote:
>>> Building with the attached random configuration file,
>>>
>>> In file included from drivers/net/wireless/ath/ath9k/eeprom.h:22:0,
>>>                  from drivers/net/wireless/ath/ath9k/hw.h:27,
>>>                  from drivers/net/wireless/ath/ath9k/dfs.c:18:
>>> drivers/net/wireless/ath/ath9k/dfs.c: In function =E2=80=98ath9k_df=
s_process_phyerr=E2=80=99:
>>> drivers/net/wireless/ath/ath9k/dfs.c:185:14: error: =E2=80=98struct=
 ath_softc=E2=80=99
>>> has no member named =E2=80=98debug=E2=80=99
>>>     pe.ts - sc->debug.stats.dfs_stats.last_ts);
>>>               ^
>>> drivers/net/wireless/ath/ath9k/../ath.h:273:41: note: in definition=
 of
>>> macro =E2=80=98ath_dbg=E2=80=99
>>>    ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__); \
>>>                                          ^
>>> drivers/net/wireless/ath/ath9k/dfs.c:186:5: error: =E2=80=98struct =
ath_softc=E2=80=99
>>> has no member named =E2=80=98debug=E2=80=99
>>>    sc->debug.stats.dfs_stats.last_ts =3D pe.ts;
>>>      ^
>>> make[5]: *** [drivers/net/wireless/ath/ath9k/dfs.o] Error 1
>>
>> Please select CONFIG_ATH9K_DEBUGFS.
>=20
> The point of randconfig builds is to ensure that there it's really
> unlikely that there are any config combinations that don't build, eve=
n
> if they're utterly insane.
>=20
> You should really change the ath9k Kconfig rules or move or add ifdef=
s
> to prevent this from being possible.
>=20
> Thanks,
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
