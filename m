From: Greg KH <gregkh@suse.de>
Subject: Re: [GIT] Networking
Date: Tue, 25 Oct 2011 13:56:34 +0200
Message-ID: <20111025115634.GA12128@suse.de>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
 <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 01:46:11PM +0200, Linus Torvalds wrote:
> Greg - please fix your crazy tools. Look at this:
> 
>    git log fs/sysfs/dir.c
> 
> and tell me why the f*&% you have commit messages like this:
> 
>   commit 4f72c0cab40536a0be501d85ea4918467ab82ad5
>   Author: Mikulas Patocka <mpatocka@redhat.com>
>   Date:   Mon Jul 25 17:55:57 2011 -0400
> 
>       sysfs: use rb-tree for name lookups
> 
>       sysfs: use rb-tree for name lookups

The "crazy" tool was using 'git am'.  The problem was that I missed the
fact that the first line of the patch sent to me duplicated the subject
line.  It's a really common problem when people generate patches and
send them off by email, I just forgot to edit the patches from Mikulas
to remove them, my fault, sorry.

greg k-h
