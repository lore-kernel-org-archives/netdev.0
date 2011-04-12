From: David Miller <davem@davemloft.net>
Subject: Re: fix locking unbalance in irda_sendmsg
Date: Tue, 12 Apr 2011 15:30:14 -0700 (PDT)
Message-ID: <20110412.153014.242140030.davem@davemloft.net>
References: <20110412221254.GA23906@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davej@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110412221254.GA23906@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Tue, 12 Apr 2011 18:12:55 -0400

> 5b40964eadea40509d353318d2c82e8b7bf5e8a5 introduced a path where
> we have a locking unbalance.  If we pass invalid flags, we unlock
> a socket we never locked, resulting in this...
 ...
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied and queued up for -stable, thanks Dave.
