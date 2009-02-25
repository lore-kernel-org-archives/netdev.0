From: Rob Landley <rob@landley.net>
Subject: Re: Documentation:Update the INDEX of the documents
Date: Wed, 25 Feb 2009 13:30:48 -0600
Message-ID: <200902251330.49640.rob@landley.net>
References: <49A4F06B.6030205@cn.fujitsu.com> <20090225145950.GJ7064@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Yang Hongyang <yanghy@cn.fujitsu.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-doc@vger.kernel.org, mtk.manpages@gmail.com,
	rdunlap@xenotime.net
To: Theodore Tso <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:38965
	"EHLO grelber.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756961AbZBYTaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 14:30:52 -0500
In-Reply-To: <20090225145950.GJ7064@mit.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 25 February 2009 08:59:50 Theodore Tso wrote:
> On Wed, Feb 25, 2009 at 03:16:59PM +0800, Yang Hongyang wrote:
> > There are so many 00-INDEX file that are missing description of the
> > current files in the dir.  Such as 00-INDEX in
> > Documentation/x86/,Documentation/networking/,Documentation/ and so
> > on.
> >
> > It's a large amount of work for someone to go through all these
> > documents and make summaries.
> >
> > I'm willing to do some of the work but if someone else pick these
> > up(especially the authors of these new files) it will be a great
> > help.^_^
>
> Before you embark on this large amount of work, we should probably ask
> a question first --- how useful are the 00-INDEX files?  I don't find
> them particularly interesting, given that my normal way of finding
> documentation in the Documentation directory is:
>
> find . -type f | xargs grep <keyword>
>
> Or, if I have a git tree of the Linux sources handy:
>
> git grep <keyword> -- Documentation
>
> If folks do find the 00-INDEX files useful, my suggestion would be to
> make a way of automatically extracting them from the individual files
> and/or directories, and then making the 00-INDEX files to be
> automatically generated.

I have a script that automatically generates html indexes from them for 
http://kernel.org/doc/Documentation which is at least a use. :)

I'd be happy to generate those html indexes from something else, but there 
isn't an obvious reliable source of single line comments in the files 
themselves.  For a lot of 'em you can take the first nonblank line and ignore 
things like the trailing colon in unshare.txt, and maybe you could even 
automatically ignore things like the sentence fragment at the end of kref.txt.

But what do you do about the first like of IRQ-affinity.txt being 
"ChangeLog:", or hw_random.txt starting with "Introduction:"?  (And of course 
logo.gif isn't a text file.  And we haven't even gotten to the 
subdirectories...)

Rob
