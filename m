From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Nov 15 (pch_gbe)
Date: Fri, 16 Nov 2012 13:48:41 -0800
Message-ID: <50A6B4B9.4060804@xenotime.net>
References: <20121115181740.4fb08780f0b92149a5ed2ca4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LAPIS SEMICONDUCTOR <tshimizu818@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121115181740.4fb08780f0b92149a5ed2ca4@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2012 11:17 PM, Stephen Rothwell wrote:

> Hi all,
> 
> News: this one will be the last release until next-20121126 (which should
> be just be after -rc7, I guess - assuming that Linus does not release
> v3.7 before then).
> 
> Changes since 20121114:
> 


on x86_64:

drivers/built-in.o: In function `pch_tx_timestamp':
pch_gbe_main.c:(.text+0x5b9b08): undefined reference to `pch_ch_event_read'
pch_gbe_main.c:(.text+0x5b9b39): undefined reference to `pch_tx_snap_read'
pch_gbe_main.c:(.text+0x5b9b6c): undefined reference to `pch_ch_event_write'
drivers/built-in.o: In function `pch_rx_timestamp':
pch_gbe_main.c:(.text+0x5ba648): undefined reference to `pch_ch_event_read'
pch_gbe_main.c:(.text+0x5ba658): undefined reference to `pch_src_uuid_lo_read'
pch_gbe_main.c:(.text+0x5ba663): undefined reference to `pch_src_uuid_hi_read'
pch_gbe_main.c:(.text+0x5ba709): undefined reference to `pch_ch_event_write'
pch_gbe_main.c:(.text+0x5ba717): undefined reference to `pch_rx_snap_read'
drivers/built-in.o: In function `hwtstamp_ioctl.clone.13':
pch_gbe_main.c:(.text+0x5bb3b0): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x5bb3c9): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x5bb3e2): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x5bb406): undefined reference to `pch_ch_control_write'
pch_gbe_main.c:(.text+0x5bb426): undefined reference to `pch_set_station_address'
pch_gbe_main.c:(.text+0x5bb433): undefined reference to `pch_ch_event_write'

when PTP_1588_CLOCK_PCH is not enabled.

Want to select PTP_1588_CLOCK_PCH for PCH_GBE?

-- 
~Randy
