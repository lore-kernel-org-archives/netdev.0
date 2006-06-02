From: Anand Kumria <wildfire@progsoc.uts.edu.au>
Subject: Re: RFC3927 ARP patch status?
Date: Sat, 3 Jun 2006 03:31:44 +1000
Message-ID: <20060602173144.GG549@progsoc.uts.edu.au>
References: <20060602143837.GF549@progsoc.uts.edu.au> <44806926.1050509@avtrex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from incubus.progsoc.uts.edu.au ([138.25.6.7]:22437 "EHLO
	incubus.progsoc.uts.edu.au") by vger.kernel.org with ESMTP
	id S1751335AbWFBRbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 13:31:46 -0400
To: David Daney <ddaney@avtrex.com>
Content-Disposition: inline
In-Reply-To: <44806926.1050509@avtrex.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 09:36:54AM -0700, David Daney wrote:
> Anand Kumria wrote:
> >Hi David,
> >
> >Do you know the status of your RFC3927 ARP patch? Is it likely to make
> >it into a mainline kernel?
> >
> 
> That would be up to the kernel network maintainers.
> 
> There were some discussions about whether it made sense for the kernel 
> to support the behavior required by the RFC.  Other comments debated the 

Hmm, well the behaviour at the moment is certainly suboptimal. Any
compliant RFC3927 implementation has to generate an additional broadcast
ARP -- the kernel will send a directed response, which isn't enough.

> The patch is there.  I signed-off-by on it.
> 
> If you need RFC3927 compliance, you are free to apply the patch.  If the 
>  network maintainers are so inclined, they can do the necessary things 
> to get it into the mainline.

Okay, thanks.

Anand

-- 
 `When any government, or any church for that matter, undertakes to say to
  its subjects, "This you may not read, this you must not see, this you are
  forbidden to know," the end result is tyranny and oppression no matter how
  holy the motives' -- Robert A Heinlein, "If this goes on --"
