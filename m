From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcm80211: drop unreachable else case
Date: Thu, 26 Feb 2015 13:03:53 +0000 (UTC)
Message-ID: <20150226130354.06FE5140580@smtp.codeaurora.org>
References: <1423229210-7313-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Fabian Frederick <fabf@skynet.be>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423229210-7313-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> the if/elseif/else is exhaustive - there is no 4th case given the 
>   rssi_ctrl_mask = RADIO_2055_NBRSSI_SEL | RADIO_2055_WBRSSI_G1_SEL | 
>   RADIO_2055_WBRSSI_G2_SEL;
> so this unreachable else case (dead code) can be dropped.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
