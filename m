From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [ath9k-devel] randconfig build error with next-20140519, in drivers/net/wireless/ath/ath9k/dfs.c
Date: Wed, 21 May 2014 22:12:26 +1000
Message-ID: <CAGRGNgXuS-ksFBAtmo8nLAPqPFKo2gHGDCsTcranU-k2-K3rfg@mail.gmail.com>
References: <CA+r1ZhiM7EK08Y4kriXMugMc1Mbj5VDUPwKMq8-_k8Q8qhwPtw@mail.gmail.com>
 <20140521110143.GA2375@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linville <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	ath9k-devel@lists.ath9k.org, netdev <netdev@vger.kernel.org>
To: Rajkumar Manoharan <rmanohar@qti.qualcomm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140521110143.GA2375@qca.qualcomm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rajkumar,

On Wed, May 21, 2014 at 9:01 PM, Rajkumar Manoharan
<rmanohar@qti.qualcomm.com> wrote:
> On Mon, May 19, 2014 at 09:31:16AM -0700, Jim Davis wrote:
>> Building with the attached random configuration file,
>>
>> In file included from drivers/net/wireless/ath/ath9k/eeprom.h:22:0,
>>                  from drivers/net/wireless/ath/ath9k/hw.h:27,
>>                  from drivers/net/wireless/ath/ath9k/dfs.c:18:
>> drivers/net/wireless/ath/ath9k/dfs.c: In function =E2=80=98ath9k_dfs=
_process_phyerr=E2=80=99:
>> drivers/net/wireless/ath/ath9k/dfs.c:185:14: error: =E2=80=98struct =
ath_softc=E2=80=99
>> has no member named =E2=80=98debug=E2=80=99
>>     pe.ts - sc->debug.stats.dfs_stats.last_ts);
>>               ^
>> drivers/net/wireless/ath/ath9k/../ath.h:273:41: note: in definition =
of
>> macro =E2=80=98ath_dbg=E2=80=99
>>    ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__); \
>>                                          ^
>> drivers/net/wireless/ath/ath9k/dfs.c:186:5: error: =E2=80=98struct a=
th_softc=E2=80=99
>> has no member named =E2=80=98debug=E2=80=99
>>    sc->debug.stats.dfs_stats.last_ts =3D pe.ts;
>>      ^
>> make[5]: *** [drivers/net/wireless/ath/ath9k/dfs.o] Error 1
>
> Please select CONFIG_ATH9K_DEBUGFS.

The point of randconfig builds is to ensure that there it's really
unlikely that there are any config combinations that don't build, even
if they're utterly insane.

You should really change the ath9k Kconfig rules or move or add ifdefs
to prevent this from being possible.

Thanks,

--=20
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
=2EPlan: http://sites.google.com/site/juliancalaby/
