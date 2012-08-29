From: David Miller <davem@davemloft.net>
Subject: Re: "netpoll: re-enable irq in poll_napi()" breaks boot with
 netconsole
Date: Wed, 29 Aug 2012 14:59:47 -0400 (EDT)
Message-ID: <20120829.145947.282734125016260299.davem@davemloft.net>
References: <20120829185329.GA2734@joi.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: marcin.slusarz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120829185329.GA2734@joi.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Slusarz <marcin.slusarz@gmail.com>
Date: Wed, 29 Aug 2012 20:53:29 +0200

> Kernel 3.6-rc3 does not boot for me with netconsole enabled, while 3.6-rc2 did.
> I bisected it to commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d "netpoll:
> re-enable irq in poll_napi()" and reverting it on top of current Linus' tree
> restores proper behaviour (disabling netconsole does this too).
> "Not booting" manifests as immediate hang after network card enabling.

Fix is already pending, thanks:

http://patchwork.ozlabs.org/patch/179954/
