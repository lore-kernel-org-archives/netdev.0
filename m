From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/3] seq_file: add RCU versions of new hlist/list
 iterators (v3)
Date: Fri, 19 Feb 2010 22:22:39 +0000
Message-ID: <20100219222239.GN30031@ZenIV.linux.org.uk>
References: <20100219215913.819285957@vyatta.com>
 <20100219220111.692855800@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55843 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755872Ab0BSWXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 17:23:39 -0500
Content-Disposition: inline
In-Reply-To: <20100219220111.692855800@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2010 at 01:59:14PM -0800, Stephen Hemminger wrote:
> Many usages of seq_file use RCU protected lists, so non RCU
> iterators will not work safely.

Looks sane, provided that you give strong warnings about access to
contents of list elements...
