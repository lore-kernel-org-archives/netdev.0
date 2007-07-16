From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] crash in 2.6.22-git2 sysctl_set_parent()
Date: Mon, 16 Jul 2007 12:25:35 -0500
Message-ID: <20070716172535.GB5771@austin.ibm.com>
References: <20070713200515.GS5549@austin.ibm.com> <20070713.154702.17863636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49039 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbXGPRZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:25:39 -0400
Content-Disposition: inline
In-Reply-To: <20070713.154702.17863636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 03:47:02PM -0700, David Miller wrote:
> From: linas@austin.ibm.com (Linas Vepstas)
> Date: Fri, 13 Jul 2007 15:05:15 -0500
> 
> > 
> > This is a patch (& bug report) for a crash in sysctl_set_parent() 
> > in 2.6.22-git2. 
> > 
> > Problem: 2.6.22-git2 crashes with a stack trace 
> > 
> > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> Thanks for tracking this down, I'll apply your patch.

NAK. As I just explained in another email, this bug
was introduced by the "send-to-self" patch I habitually
apply -- so habitually, that I forgot I was not working 
with a "clean" tree. So it goes ... 

--linas
