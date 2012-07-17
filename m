From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: That's pretty much it for 3.5.0
Date: Tue, 17 Jul 2012 17:41:55 +0000
Message-ID: <997C449C-D599-4F46-A0A3-A2B869DEE36E@intel.com>
References: <20120717.090142.125145009944045241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
	"<netfilter-devel@vger.kernel.org>" <netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120717.090142.125145009944045241.davem@davemloft.net>
Content-Language: en-US
Content-ID: <2FAFF28D136CBE4EAF5701E586B8CEB7@intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jul 17, 2012, at 9:01 AM, David Miller wrote:

> Linus was _extremely_ generous and took in all the stuff that was
> pending in the net tree just now.

Maybe *too* generous. :-) I just updated and when I boot I get an early crash in update_netdev_tables which is in netprio_cgroup.c.

> Besides very serious issues, I'm not willing to consider any more bug
> fixes for the 'net' tree at this time.

I think the above issue will have to be fixed, as it completely prevents booting for any kernel that includes the netprio_cgroup option.

> Only one pending known bug qualifies, and that's the CIPSO ip option
> processing OOPS'er.  And I'll work on that myself if Paul Moore
> doesn't show a sign of life in the next day.
> 
> Thanks.


I can start taking a look at this if you like, but I see that Gao feng has two patches in the last set of patches that may be related.

To give you an idea how early the crash is, here are a few log messages leading up to it:

[    0.003455] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.005550] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.007165] Mount-cache hash table entries: 256
[    0.010289] Initializing cgroup subsys net_cls
[    0.010947] Initializing cgroup subsys net_prio
[    0.011039] BUG: unable to handle kernel NULL pointer dereference at 0000000000000828
[    0.011998] IP: [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0

-- 
Mark Rustad, LAN Access Division, Intel Corporation

