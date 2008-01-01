From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH 00/26] atl1: divide and modernize
Date: Tue, 1 Jan 2008 12:12:17 -0600
Message-ID: <20080101121217.09337d8a@osprey.hogchain.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
	<20080101175839.GA25201@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Snook <csnook@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:45463 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbYAASRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 13:17:20 -0500
In-Reply-To: <20080101175839.GA25201@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jan 2008 17:58:40 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Dec 31, 2007 at 08:22:27PM -0600, Jay Cliburn wrote:

> > The first two patches submitted in this patchset accomplish the
> > relocation by movng the atl1 driver -- lock, stock, and barrel --
> > over to drivers/net/atlx, then splitting out shareable functions
> > and definitions. Some transitory hackery will be present until the
> > atl2 merge.  Please overlook it for now.

> How much shared code is going to be there in the end?  Unless it's a
> lot I fear that the maintaince burden far outweights the benefit of
> having shared code.

Christoph,

I'm not working on the atl2 merge other than to make accommodations for
it within atl1.  I've added Chris Snook to the cc list; he's working on
atl2.

Jay
