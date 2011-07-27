From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: reduce noise during init
Date: Tue, 26 Jul 2011 21:05:09 -0400
Message-ID: <20110727010509.GR21309@gospo.rdu.redhat.com>
References: <1311716107-12328-1-git-send-email-andy@greyhouse.net> <1311717286.15386.34.camel@Joe-Laptop> <11239.1311727039@death> <1311727227.15386.40.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957Ab1G0BFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 21:05:14 -0400
Content-Disposition: inline
In-Reply-To: <1311727227.15386.40.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2011 at 05:40:27PM -0700, Joe Perches wrote:
> On Tue, 2011-07-26 at 17:37 -0700, Jay Vosburgh wrote:
> > Joe Perches <joe@perches.com> wrote:
> > >I'd prefer you don't separate the format string
> > >into multiple pieces.
> > Why not?  To me, it looks easier to read split into sections
> > that don't wrap lines.
> 
> Harder to grep for a dmesg and the
> defect rate of these split formats is
> typically higher than single strings
> because of bad spacing between string
> segments.
> 

I'll agree that grepping based on dmesg/log output can be more
difficult, but the visual benefit when looking at the code makes this
really nice.  That is why I would prefer to breakup long strings when
changing nearby code.

If spacing is incorrect it should simply be fixed -- that's not a
compelling reason to prevent splitting strings into multiple lines.

