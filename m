From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] brcmfmac: dhd_sdio.c: use existing atomic_or
 primitive
Date: Thu, 9 Jul 2015 21:57:37 +0200
Message-ID: <20150709195737.GA26965@worktop.ger.corp.intel.com>
References: <1436429599-10762-1-git-send-email-vgupta@synopsys.com>
 <1436429599-10762-3-git-send-email-vgupta@synopsys.com>
 <559EBC91.2070600@broadcom.com>
 <559EBDF4.7030808@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Ingo Molnar <mingo@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <559EBDF4.7030808@broadcom.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 09, 2015 at 08:31:16PM +0200, Arend van Spriel wrote:
> >There is or there was? If there is now I am fine with this patch, but if
> >it already was there the author might have had a reason for adding a
> >local function and I would like to hear that reason.
> 
> Nevermind. Just noticed you are proposing the generic implementation in this
> series. Currently on vacation and want to discuss with Hante about this
> change.

No there is one in linux/atomic.h, he just renamed the #ifdef guard and
provided a 'sane' implementation for his arch.
