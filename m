From: Ben Liblit <liblit@acm.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Mon, 05 May 2008 18:38:48 -0500
Message-ID: <481F9A88.2010102@acm.org>
References: <bug-10600-10286@http.bugzilla.kernel.org/> <20080505155502.3fb16590.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pumice.cs.wisc.edu ([128.105.6.29]:45720 "EHLO
	pumice.cs.wisc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889AbYEFA3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 20:29:34 -0400
In-Reply-To: <20080505155502.3fb16590.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> I've noticed that when I'm downloading stuff at home, gkrellm will display
> eth0 as consuming 0 kbytes/sec, then 400 kbytes/sec, then 0, then 400 ad
> nauseum.  I always assumed that gkrellm was busted.  Perhaps wrongly...

Likewise, my initial assumption was that GNOME System Monitor was 
faulty.  You might try the command that I suggested in my original report:

    watch -d -n 0.25 'cat /sys/class/net/eth0/statistics/rx_bytes'

Run that during a big download and it should be pretty clear whether 
it's being updated frequently or not.  If not, then gkrellm is not to blame.
