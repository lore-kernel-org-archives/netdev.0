From: Thomas Graf <tgraf@suug.ch>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: Mon, 28 Mar 2005 14:38:01 +0200
Message-ID: <20050328123801.GY3086@postel.suug.ch>
References: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee> <1111972035.1091.946.camel@jzny.localdomain> <Pine.SOC.4.61.0503281017060.21333@math.ut.ee> <1112012657.1089.1013.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Meelis Roos <mroos@linux.ee>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112012657.1089.1013.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1112012657.1089.1013.camel@jzny.localdomain> 2005-03-28 07:24
> If we are going to make u32 an exception then this code should be
> surrounded by #ifdef ..ACTION..

The same condition is needed for tcf_exts_dump and tcf_exts_dump_stats
in u32, they're only apart to cut the TCA_OPTIONS nested TLV so I'm
trying to find out is whether we can get rid of dump_stats alltogether
and hide it. I'm working on a patch to do this, I hope to have enough time
to finish it today.

> My time is about to become scarce, so if you
> have time please create the patch.

Again, don't waste cycles on this. It was my fault and I will fix it. ;->
