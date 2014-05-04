From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sun, 4 May 2014 23:19:28 +0200
Message-ID: <20140504211928.GB4471@electric-eye.fr.zoreil.com>
References: <20140502175242.GB1156@newterm.pl>
 <20140503114029.GA19315@electric-eye.fr.zoreil.com>
 <20140504110413.GE1156@newterm.pl>
 <20140504184351.GA4471@electric-eye.fr.zoreil.com>
 <20140504194624.GG1156@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140504194624.GG1156@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darek Marcinkiewicz <reksio@newterm.pl> :
> On Sun, May 04, 2014 at 08:43:51PM +0200, Francois Romieu wrote:
[...]
> > Regarding tx_dnext updates, you may add a short notice in ec_bhf_start_xmit
> > and ec_bhf_process_tx explaining that the periodic poller will somehow end
> > working with the right value, whence no (smp_)barrier at all.
> > 
> Hmm, good point. I am not really sure that it is not a race. So, I've added
> memory barriers for the case when the tx ring becomes full.

Without memory barrier, the hrtimer poller may be wrong but 1) it will
always be pessimistic and 2) it won't last. It would be sloppy though.

Did you have some time to test the latest version ?

-- 
Ueimor
