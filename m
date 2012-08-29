From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: "netpoll: re-enable irq in poll_napi()" breaks boot with netconsole
Date: Wed, 29 Aug 2012 20:53:29 +0200
Message-ID: <20120829185329.GA2734@joi.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Kernel 3.6-rc3 does not boot for me with netconsole enabled, while 3.6-rc2 did.
I bisected it to commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d "netpoll:
re-enable irq in poll_napi()" and reverting it on top of current Linus' tree
restores proper behaviour (disabling netconsole does this too).
"Not booting" manifests as immediate hang after network card enabling.

Cheers,
Marcin
