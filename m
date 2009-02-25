From: Theodore Tso <tytso@mit.edu>
Subject: Re: Documentation:Update the INDEX of the documents
Date: Wed, 25 Feb 2009 10:56:28 -0500
Message-ID: <20090225155628.GM7064@mit.edu>
References: <49A4F06B.6030205@cn.fujitsu.com> <20090225145950.GJ7064@mit.edu> <a669f14b0902250725j4c21463eqc1b88092486f38ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yang Hongyang <yanghy@cn.fujitsu.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-doc@vger.kernel.org, mtk.manpages@gmail.com,
	rdunlap@xenotime.net
To: Yang Hongyang <imhy.yang@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a669f14b0902250725j4c21463eqc1b88092486f38ad@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2009 at 11:25:08PM +0800, Yang Hongyang wrote:
> > If folks do find the 00-INDEX files useful, my suggestion would be to
> > make a way of automatically extracting them from the individual files
> > and/or directories, and then making the 00-INDEX files to be
> > automatically generated.
> 
> Sounds like a good idea but How to automatically generate
>  the summaries then?

Well, for text files (including subdirectory's 00-INDEX files) we
could have a convention which is the first line of the file should be
a (max 60 characters) one-line summary of the file.

We would probably have to do something special with non-free-form-text
files, including structured text files like Docbook files.  So it's
not quite so straightforward, but it should be doable.

    	     		      	     	       - Ted
