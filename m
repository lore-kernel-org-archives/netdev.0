From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [0/3] Distributed storage. Mirror algo extension for automatic recovery.
Date: Sat, 27 Oct 2007 14:34:59 +0400
Message-ID: <20071027103459.GA14698@2ka.mipt.ru>
References: <20071018191741.GA848@2ka.mipt.ru> <20071026135538.d22125a2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60829 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbXJ0KfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Oct 2007 06:35:07 -0400
Content-Disposition: inline
In-Reply-To: <20071026135538.d22125a2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew.

On Fri, Oct 26, 2007 at 01:55:38PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > I'm pleased to announce sixth release of the distributed storage
> > subsystem, which allows to form a storage on top of remote and local
> > nodes, which in turn can be exported to another storage as a node to
> > form tree-like storages.
> 
> I went back and re-read last month's discussion and I'm not seeing any
> reason why we shouldn't start thinking about merging this.
> 
> How close is it to that stage?  A peek at your development blog indicates
> that things are still changing at a moderate rate?

I completed storage layer development itself, the only remaining todo item
is to implement new redundancy algorithm, but I did not see major demand
on that, so it will stay for now with low priority.

I will use DST as a transport layer for distributed filesystem, and
probably that will require additional features, I have no clean design so
far, but right now I have nothing in the pipe to commit to DST.


-- 
	Evgeniy Polyakov
