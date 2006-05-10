From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] bonding: fix sparse warnings
Date: Thu, 11 May 2006 00:22:03 +0100
Message-ID: <20060510232203.GK27946@ftp.linux.org.uk>
References: <20060510161405.4ded4250@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ctindel@users.sourceforge.net, Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56242 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S965077AbWEJXWL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 19:22:11 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060510161405.4ded4250@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 10, 2006 at 04:14:05PM -0700, Stephen Hemminger wrote:
> Fix warning from sparse in bonding code about "incorrect type in assignment"

*snerk*

Only if you are building without -Wcast-to-as.  It _is_ incorrect type in
assignment.  And the real fix is to expand the call, killing set_fs()
in there.
