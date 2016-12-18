From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: regression: ath_tx_edma_tasklet() Illegal idle entry in RCU
 read-side critical section
Date: Sun, 18 Dec 2016 12:14:10 -0800
Message-ID: <20161218201410.GS3924@linux.vnet.ibm.com>
References: <23a2a3ab-974a-ed26-6afa-aafab9bb972e@gmail.com>
 <20161218155938.GP3924@linux.vnet.ibm.com>
 <58b67d5b-0275-f80f-479f-78cf748b4319@mni.thm.de>
 <87pokpc8ng.fsf@qca.qualcomm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>,
        Gabriel C <nix.or.die@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        ath9k-devel <ath9k-devel@qca.qualcomm.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nbd@nbd.name" <nbd@nbd.name>
To: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87pokpc8ng.fsf@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 18, 2016 at 07:57:42PM +0000, Valo, Kalle wrote:
> Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de> writes:
> 
> > A patch for this is already floating on the ML for a while now latest:
> > (ath9k: do not return early to fix rcu unlocking)
> 
> It's here:
> 
> https://patchwork.kernel.org/patch/9472709/

Feel free to add:

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

							Thanx, Paul

> > Hopefully Kalle will include it in one of his upcoming pull requests.
> 
> Yes, I'll try to get it to 4.10-rc2.
> 
> -- 
> Kalle Valo
