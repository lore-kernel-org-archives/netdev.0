From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/9] task_struct: add PF_NONOTIFY for fanotify to use
Date: Sat, 29 Aug 2009 02:50:20 +0400
Message-ID: <20090828225020.GA11259@ioremap.net>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com> <20090828223626.GA8283@ioremap.net> <1251499168.28787.2.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751129AbZH1WuU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1251499168.28787.2.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 28, 2009 at 06:39:28PM -0400, Eric Paris (eparis@redhat.com) wrote:
> > Is there a way to get old-school notifications with the object
> > information instead of opened file desriptor, which may suffer rlimit
> > problems and scalability issues with too many opened/closed descriptors?
> 
> Use inotify.

I need pids.

-- 
	Evgeniy Polyakov
