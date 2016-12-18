From: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Subject: Re: regression: ath_tx_edma_tasklet() Illegal idle
 entry in RCU read-side critical section
Date: Sun, 18 Dec 2016 19:57:42 +0000
Message-ID: <87pokpc8ng.fsf@qca.qualcomm.com>
References: <23a2a3ab-974a-ed26-6afa-aafab9bb972e@gmail.com>
	<20161218155938.GP3924@linux.vnet.ibm.com>
	<58b67d5b-0275-f80f-479f-78cf748b4319@mni.thm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Gabriel C <nix.or.die@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	ath9k-devel <ath9k-devel@qca.qualcomm.com>,
	lkml <linux-kernel@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"nbd@nbd.name" <nbd@nbd.name>
To: Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <58b67d5b-0275-f80f-479f-78cf748b4319@mni.thm.de> (Tobias
	Klausmann's message of "Sun, 18 Dec 2016 17:17:54 +0100")
Content-Language: en-US
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de> writes:

> A patch for this is already floating on the ML for a while now latest:
> (ath9k: do not return early to fix rcu unlocking)

It's here:

https://patchwork.kernel.org/patch/9472709/

> Hopefully Kalle will include it in one of his upcoming pull requests.

Yes, I'll try to get it to 4.10-rc2.

-- 
Kalle Valo
