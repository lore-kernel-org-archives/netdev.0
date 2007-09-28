From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [stable] [PATCH 2/3] sky2: fix VLAN receive processing
Date: Fri, 28 Sep 2007 12:36:21 -0700
Message-ID: <20070928123621.6a430736@freepuppy.rosehill>
References: <20070928164811.387831540@linux-foundation.org>
	<20070928164858.539587428@linux-foundation.org>
	<20070928192044.GH3906@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org, stable@kernel.org,
	Pierre-Yves Ritschard <pyr@spootnik.org>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40825 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752311AbXI1The (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 15:37:34 -0400
In-Reply-To: <20070928192044.GH3906@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 12:20:44 -0700
Chris Wright <chrisw@sous-sol.org> wrote:

> * Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> > The length check for truncated frames was not correctly handling
> > the case where VLAN acceleration had already read the tag.
> > Also, the Yukon EX has some features that use high bit of status
> > as security tag.
> 
> Did you leave out the GMR_FS_LEN change on purpose?  AFAICT, w/out
> that you miss the Yukon EX high bit usage.  The upstream patch applies,
> can we simply use that one (below rediffed for stable)?
> 
> thanks,
> -chris
>

I left it out on purpose because 2.6.22 doesn't support Yukon EX.
