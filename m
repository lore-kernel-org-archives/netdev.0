From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 3/3] staging/rtl8192u: use s8 instead of char
Date: Tue, 19 Jul 2016 11:47:10 -0400
Message-ID: <wrfjtwflvddt.fsf@redhat.com>
References: <20160719153403.2967812-1-arnd@arndb.de>
	<20160719153403.2967812-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	=?utf-8?Q?Rapha=C3=ABl?= Beamonte <raphael.beamonte@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719153403.2967812-3-arnd@arndb.de> (Arnd Bergmann's message
	of "Tue, 19 Jul 2016 17:33:02 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:
> Compiling the rtlwifi drivers for ARM with gcc -Wextra warns about lots of
> incorrect code that results from 'char' being unsigned here, e.g.
>
> staging/rtl8192u/r8192U_core.c:4150:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> staging/rtl8192u/r8192U_dm.c:646:50: error: comparison is always false due to limited range of data type [-Werror=type-limits]
>
> This patch changes all uses of 'char' in this driver that refer to
> 8-bit integers to use 's8' instead, which is signed on all architectures.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/staging/rtl8192u/ieee80211/ieee80211.h |  4 ++--
>  drivers/staging/rtl8192u/r8192U.h              |  4 ++--
>  drivers/staging/rtl8192u/r8192U_core.c         | 14 +++++++-------
>  3 files changed, 11 insertions(+), 11 deletions(-)

Looks good to me

Acked-by: Jes Sorensen <Jes.Sorensen@redhat.com>
