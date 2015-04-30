From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen_nic: use spin_[un]lock_bh around tx_clean_lock
Date: Thu, 30 Apr 2015 16:37:42 -0400 (EDT)
Message-ID: <20150430.163742.1867744843397612112.davem@davemloft.net>
References: <1430394687-78627-1-git-send-email-tcamuso@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, nhorman@redhat.com
To: tcamuso@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430394687-78627-1-git-send-email-tcamuso@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Camuso <tcamuso@redhat.com>
Date: Thu, 30 Apr 2015 07:51:27 -0400

> While testing this driver with DEBUG_LOCKDEP and DEBUG_SPINLOCK
> enabled did not produce any traces, it would be more prudent in the
> case of tx_clean_lock to use spin_[un]lock_bh, since this lock is
> manipulated in both the process and softirq contexts.
> 
> This patch was tested for functionality and regressions with netperf
> and DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled.
> 
> Signed-off-by: Tony Camuso <tcamuso@redhat.com>

Applied, thanks Tony.
