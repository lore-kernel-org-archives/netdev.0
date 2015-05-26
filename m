From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: avoid gcc-5.1 warning
Date: Tue, 26 May 2015 10:54:10 +0000 (UTC)
Message-ID: <20150526105410.13F6F1416C2@smtp.codeaurora.org>
References: <2201884.BixNBcLJhn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Franky Lin <frankyl@broadcom.com>,
 brcm80211-dev-list@broadcom.com, "John W. Linville" <linville@tuxdriver.com>,
 Pieter-Paul Giesberts <pieterpg@broadcom.com>,
 Hante Meuleman <meuleman@broadcom.com>, netdev@vger.kernel.org,
 Brett Rudley <brudley@broadcom.com>, Arend Van Spriel <arend@broadcom.com>,
 linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <2201884.BixNBcLJhn@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


> gcc-5.0 gained a new warning in the fwsignal portion of the brcmfmac
> driver:
> 
> drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c: In function 'brcmf_fws_txs_process':
> drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c:1478:8: warning: 'skb' may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> This is a false positive, and marking the brcmf_fws_hanger_poppkt function
> as 'static inline' makes the warning go away. I have checked the object
> file output and while a little code gets moved around, the size of
> the binary remains identical.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
