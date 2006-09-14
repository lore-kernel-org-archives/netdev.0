From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: examples to model ethernet driver off of?
Date: Thu, 14 Sep 2006 10:26:10 +0900
Message-ID: <20060914102610.6e4dc766@localhost.localdomain>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org>
	<20060913195445.GH25007@electric-eye.fr.zoreil.com>
	<450865DB.4040809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49851 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751324AbWINB0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 21:26:20 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <450865DB.4040809@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2006 13:11:07 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> Francois Romieu wrote:
> > Kumar Gala <galak@kernel.crashing.org> :
> >> What are good examples of simple/basic ethernet drivers one should  
> >> use to model a new driver off of?
> > 
> > tg3/bnx2/sky2/b44/8139cp
> 
> Can I add e1000/ixgb to that? ;)

sorry to pick on e1000, but the code is too verbose and
split over too many files.  The e100 code is much cleaner.
