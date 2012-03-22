From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost-net/virtio: fixes for 3.4
Date: Fri, 23 Mar 2012 00:12:28 +0200
Message-ID: <20120322221227.GA17849@redhat.com>
References: <20120320145010.GA31570@redhat.com>
 <20120322082718.GA11258@redhat.com>
 <20120322.165649.32205268396882350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	levinsasha928@gmail.com, nyh@il.ibm.com, nyh@math.technion.ac.il
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120322.165649.32205268396882350.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2012 at 04:56:49PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Thu, 22 Mar 2012 10:27:19 +0200
> 
> > On Tue, Mar 20, 2012 at 04:50:41PM +0200, Michael S. Tsirkin wrote:
> >> The following changes since commit 5ffca28a4ac7abb8a254fafe6bd03b2f83667df7:
> >> 
> >>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/aia21/ntfs (2012-02-27 07:59:33 -0800)
> >> 
> >> are available in the git repository at:
> >> 
> >>   ra.kernel.org:/pub/scm/linux/kernel/git/mst/vhost.git for_davem
> >> 
> >>   (ssh url as git.kernel.org seems down at the moment, when it comes up
> >>    git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git for_davem
> >>    should be the equivalent).
> 
> Neither of these URL's work for me:
> 
> [davem@drr net]$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git for_davem
> fatal: Couldn't find remote ref for_davem
> [davem@drr net]$ git pull ra.kernel.org:/pub/scm/linux/kernel/git/mst/vhost.git for_davem
> Enter passphrase for key '/home/davem/.ssh/davem': 
> Permission denied (publickey).
> fatal: The remote end hung up unexpectedly
> [davem@drr net]$ 
> 
> If you're sending me signed pull requests that thus require a newer
> version of GIT, please don't.

OK, sorry about that. Can't fix right now as I'm not at
the box that has the key but this works for me with an old git:

/usr/bin/git fetch git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git refs/tags/for_davem

You just don't get the signature checked.

-- 
MST
