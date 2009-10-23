From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Fri, 23 Oct 2009 19:18:37 +0400
Message-ID: <20091023151837.GB5394@lenovo>
References: <200910190002.39937.denys@visp.net.lb> <200910201650.10066.denys@visp.net.lb> <20091020135920.GB5181@lenovo> <200910201720.00473.denys@visp.net.lb> <20091020190821.GO5181@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-ppp@vger.kernel.org, paulus@samba.org, mostrows@earthlink.net
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091020190821.GO5181@lenovo>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Cyrill Gorcunov - Tue, Oct 20, 2009 at 11:08:21PM +0400]
...
| 
| Just to update status of the issue. The key moment is that pppoe_flush_dev
| may be called asynchronously (especially via sysfs on dev entry, for example
| we retrieve mtu of device and while we at it other process may update mtu
| via sysfs). So I'm returning pppoe_hash_lock back which should eliminate a
| number of lock complains and make locking scheme easier. All-in-one: I'm
| working on it. Just need some more time.
| 
| 	-- Cyrill

Another status update -- the patch is under testing stage. Hope we will
reveal proper patch soon (in a few days I guess).

	-- Cyrill
