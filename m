From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 1/3] igmp: make some functions void
Date: Sat, 15 Jun 2013 15:36:59 +0800
Message-ID: <1371281819.23997.0.camel@cr0>
References: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476Ab3FOHhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 03:37:08 -0400
In-Reply-To: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-15 at 15:34 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> ip_mc_leave_src() can become avoid, because even if it fails,
> the operations after it can still continue.
> 
> ip_mc_del_src() can become avoid, because no one cares and
> some errors are ignored on purpose.
> 

Oops, s/avoid/void/...
I will send v5, sorry for the typo.
