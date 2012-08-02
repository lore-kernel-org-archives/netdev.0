From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdnloop: fix and simplify isdnloop_init()
Date: Thu, 02 Aug 2012 16:21:56 -0700 (PDT)
Message-ID: <20120802.162156.1853851468137303302.davem@davemloft.net>
References: <20120802110543.GA21745@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	joe@perches.com, isdn@linux-pingi.de, linux-kernel@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120802110543.GA21745@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fengguang Wu <fengguang.wu@intel.com>
Date: Thu, 2 Aug 2012 19:05:43 +0800

> Fix a buffer overflow bug by removing the revision transform code.
> 
> [   22.016214] isdnloop-ISDN-driver Rev 1.11.6.7 
> [   22.097508] isdnloop: (loop0) virtual card added
> [   22.174400] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffff83244972
> [   22.174400] 
> [   22.436157] Pid: 1, comm: swapper Not tainted 3.5.0-bisect-00018-gfa8bbb1-dirty #129
> [   22.624071] Call Trace:
> [   22.720558]  [<ffffffff832448c3>] ? CallcNew+0x56/0x56
> [   22.815248]  [<ffffffff8222b623>] panic+0x110/0x329
> [   22.914330]  [<ffffffff83244972>] ? isdnloop_init+0xaf/0xb1
> [   23.014800]  [<ffffffff832448c3>] ? CallcNew+0x56/0x56
> [   23.090763]  [<ffffffff8108e24b>] __stack_chk_fail+0x2b/0x30
> [   23.185748]  [<ffffffff83244972>] isdnloop_init+0xaf/0xb1
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

The reason the "$Revision ..." prefix is there is so that automated
version control tools will change the string automatically when code
is committed in CVS.

In the GIT era this revision style is obsolete.

Therefore you might as well just delete this crap altogether.
