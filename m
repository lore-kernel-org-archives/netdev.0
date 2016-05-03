From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] fix infoleak in wireless
Date: Tue, 03 May 2016 22:40:44 +0200
Message-ID: <1462308044.10444.19.camel@sipsolutions.net>
References: <1462308013-6032-1-git-send-email-kjlu@gatech.edu>
	 (sfid-20160503_223714_829563_B6EE96BB)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462308013-6032-1-git-send-email-kjlu@gatech.edu> (sfid-20160503_223714_829563_B6EE96BB)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-03 at 16:40 -0400, Kangjie Lu wrote:
> The 6-bytes array =E2=80=9Cmac_addr=E2=80=9D is not initialized in th=
e dump_station
> implementations of
> =E2=80=9Cdrivers/staging/wilc1000/wilc_wfi_cfgoperations.c=E2=80=9D
> and =E2=80=9Cdrivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c=E2=80=9D=
, so all 6
> bytes may be leaked.

Like I said to you before, this makes those implementations completely
broken. I'm not going to apply this patch. If you want, feel free to
send patches to Greg to remove those dump_station implementations that
are completely broken and that can never do anything useful.

johannes
