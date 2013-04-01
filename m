From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 7/7] r8169: fix could not dump registers
Date: Tue, 2 Apr 2013 00:24:32 +0200
Message-ID: <20130401222432.GD19335@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364824539-4156-7-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364824539-4156-7-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> For new version of Fedora and Ubuntu, we see all 0xff when dumping
> the hw regs through ethtool. Using a loop to read registers could
> fix it.

If it fixes a problem which lives outside of net-next, it should target
"net", not "net-next".

"new version" does not help when a commit log can be read at any time
and/or when people try to identify patches for -stable branches. You do
not say which kernel / chipsets combination are known to exhibit the
problem.

Fundamentally, nobody can tell from the description if it is a kernel
or hardware problem nor why things work better after the change.

-- 
Ueimor
