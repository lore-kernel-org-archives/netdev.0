From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Tool for sampling /proc/net/softnet_stat statistics
Date: Mon, 7 Mar 2016 16:36:07 +0100
Message-ID: <20160307163607.1da5f17e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Google,

While playing with RPS, I needed to read stats from 
/proc/net/softnet_stat and the tools I could find [1] and [2] was not
very good.

I lack of better, I coded up my own tool softnet_stat.pl here:
 https://github.com/netoptimizer/network-testing/blob/master/bin/softnet_stat.pl

The output format/columns in /proc/net/softnet_stat is undocumented,
plus values are printed in hex.  E.g. to decode the columns you need to
read kernel function kernel softnet_seq_show() in
kernel/net/core/net-procfs.c.

To make things easier I wrote this small perl script for get
so human readable statistics from /proc/net/softnet_stat.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


[1] https://www.redhat.com/archives/rhl-list/2007-September/msg03735.html

[2] https://gist.github.com/SaveTheRbtz/172b2e2eb3cbd96b598d
