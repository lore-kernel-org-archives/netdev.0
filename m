From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: Re: [PATCH v5 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sun, 4 May 2014 23:41:17 +0200
Message-ID: <20140504214116.GI1156@newterm.pl>
References: <20140502175242.GB1156@newterm.pl>
 <20140503114029.GA19315@electric-eye.fr.zoreil.com>
 <20140504110413.GE1156@newterm.pl>
 <20140504184351.GA4471@electric-eye.fr.zoreil.com>
 <20140504194624.GG1156@newterm.pl>
 <20140504211928.GB4471@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140504211928.GB4471@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 04, 2014 at 11:19:28PM +0200, Francois Romieu wrote:
> Darek Marcinkiewicz <reksio@newterm.pl> :
> > On Sun, May 04, 2014 at 08:43:51PM +0200, Francois Romieu wrote:
> [...]
> > > Regarding tx_dnext updates, you may add a short notice in ec_bhf_start_xmit
> > > and ec_bhf_process_tx explaining that the periodic poller will somehow end
> > > working with the right value, whence no (smp_)barrier at all.
> > > 
> > Hmm, good point. I am not really sure that it is not a race. So, I've added
> > memory barriers for the case when the tx ring becomes full.
> 
> Without memory barrier, the hrtimer poller may be wrong but 1) it will
> always be pessimistic and 2) it won't last. It would be sloppy though.
> 
> Did you have some time to test the latest version ?
> 
Yes, I have this code continuously running and it looks good. This is a regular
application that I have running now, so not all interesting edge cases might have been
exercised, though.

-- 
DM
