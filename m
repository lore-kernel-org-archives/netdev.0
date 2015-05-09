From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen_nic: use spin_[un]lock_bh around tx_clean_lock
 (2)
Date: Sat, 09 May 2015 16:45:12 -0400 (EDT)
Message-ID: <20150509.164512.2163013950829969411.davem@davemloft.net>
References: <1430917758-45028-1-git-send-email-tcamuso@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, nhorman@redhat.com
To: tcamuso@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430917758-45028-1-git-send-email-tcamuso@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Camuso <tcamuso@redhat.com>
Date: Wed,  6 May 2015 09:09:18 -0400

> This patch should have been part of the previous patch having the
> same summary. See  http://marc.info/?l=linux-kernel&m=143039470103795&w=2
> Unfortunately, I didn't check to see where else this lock was used before
> submitting that patch. This should take care of it for netxen_nic, as I
> did a thorough search this time.
> 
> To recap from the original patch; although testing this driver with
> DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled did not produce any traces,
> it would be more prudent in the case of tx_clean_lock to use _bh
> versions of spin_[un]lock, since this lock is manipulated in both
> the process and softirq contexts.
> 
> This patch was tested for functionality and regressions with netperf
> and DEBUG_LOCKDEP and DEBUG_SPINLOCK enabled.
> 
> Signed-off-by: Tony Camuso <tcamuso@redhat.com>

Applied, thanks.
