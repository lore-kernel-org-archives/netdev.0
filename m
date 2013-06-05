From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v1 3/3] igmp: convert RTNL lock to a spinlock
Date: Wed, 05 Jun 2013 13:32:24 +0800
Message-ID: <1370410344.2609.9.camel@cr0>
References: <1370403211-6851-1-git-send-email-amwang@redhat.com>
	 <1370403211-6851-3-git-send-email-amwang@redhat.com>
	 <20130604205244.7d9436b2@nehalam.linuxnetplumber.net>
	 <1370409719.2609.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025Ab3FEFce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 01:32:34 -0400
In-Reply-To: <1370409719.2609.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 13:21 +0800, Cong Wang wrote:
> 
> If you mean your _ip_mc_join_group() patch, I am sure it doesn't work.
> Besides lack of lock_sock(), the locking order needs to be fixed too.
> Trust me, I tried it, the _final_ patch is ugly.
> 

Ok, I think you mean "[PATCH net-next 03/10] vxlan: move IGMP join/leave
to work queue", so never mind, I will remove the vxlan part from my
patch.
