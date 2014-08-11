From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()
Date: Mon, 11 Aug 2014 14:38:42 -0700 (PDT)
Message-ID: <20140811.143842.1765285724858937860.davem@davemloft.net>
References: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, steve.glendinning@shawell.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sanjeev_sharma@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Date: Mon, 11 Aug 2014 13:46:23 +0530

> spin_is_locked() always return false in uniprocessor configuration and therefore it
> would be advise to repalce with WARN_ON_SMP().
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>

This looks fine, applied, thanks.
