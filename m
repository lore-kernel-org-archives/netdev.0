From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/8] dcbnl: Major simplifications
Date: Fri, 15 Jun 2012 03:26:59 -0400
Message-ID: <20120615072659.GD29738@canuck.infradead.org>
References: <cover.1339591572.git.tgraf@suug.ch>
 <20120613.155541.26513304496438357.davem@davemloft.net>
 <20120614075435.GA29185@canuck.infradead.org>
 <4FDA0BFC.90807@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, lucy.liu@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39745 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab2FOH1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 03:27:03 -0400
Content-Disposition: inline
In-Reply-To: <4FDA0BFC.90807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 09:06:20AM -0700, John Fastabend wrote:
> On 6/14/2012 12:54 AM, Thomas Graf wrote:
> >On Wed, Jun 13, 2012 at 03:55:41PM -0700, David Miller wrote:
> >>Lots of deleted code, I like it :-)
> >>
> >>Applied, but could you send a follow-on patch to use BUG_ON() instead
> >>of that "if (!ptr) { /* ... */ BUG(); }" construct?
> >
> >Sure, I must have had a weak moment right there :)
> >
> 
> Nice! I'm a bit late but dumped this into my dcbnl netlink test kit
> and everything looks good so...

Thank you for testing John. Are you referring to lldp/test/nltest.c?
I only discovered it after you mentioned a test kit. I've been feeding
a list of commands through dcbtool for testing so far.

BTW, I believe you mentioned at some point, that there is a patch
available allowing non net_device based DCB users to use dcbnl.
Otherwise I would start with the effort :)
