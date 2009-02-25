From: Theodore Tso <tytso@mit.edu>
Subject: Re: Documentation:Update the INDEX of the documents
Date: Wed, 25 Feb 2009 09:59:50 -0500
Message-ID: <20090225145950.GJ7064@mit.edu>
References: <49A4F06B.6030205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-doc@vger.kernel.org, mtk.manpages@gmail.com,
	rdunlap@xenotime.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from THUNK.ORG ([69.25.196.29]:52107 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166AbZBYPAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 10:00:00 -0500
Content-Disposition: inline
In-Reply-To: <49A4F06B.6030205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 03:16:59PM +0800, Yang Hongyang wrote:
> There are so many 00-INDEX file that are missing description of the
> current files in the dir.  Such as 00-INDEX in
> Documentation/x86/,Documentation/networking/,Documentation/ and so
> on.
> 
> It's a large amount of work for someone to go through all these
> documents and make summaries.
> 
> I'm willing to do some of the work but if someone else pick these
> up(especially the authors of these new files) it will be a great
> help.^_^

Before you embark on this large amount of work, we should probably ask
a question first --- how useful are the 00-INDEX files?  I don't find
them particularly interesting, given that my normal way of finding
documentation in the Documentation directory is:

find . -type f | xargs grep <keyword>

Or, if I have a git tree of the Linux sources handy:

git grep <keyword> -- Documentation

If folks do find the 00-INDEX files useful, my suggestion would be to
make a way of automatically extracting them from the individual files
and/or directories, and then making the 00-INDEX files to be
automatically generated.

						- Ted
