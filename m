From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] change format of LSM hooks
Date: Thu, 17 Oct 2002 09:55:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017165541.GC31464@kroah.com>
References: <20021015194545.GC15864@kroah.com> <20021015.124502.130514745.davem@redhat.com> <20021015201209.GE15864@kroah.com> <20021015.131037.96602290.davem@redhat.com> <20021015202828.GG15864@kroah.com> <20021016000706.GI16966@kroah.com> <20021017142149.A23181@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com,
   linux-security-module@wirex.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20021017142149.A23181@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 17, 2002 at 02:21:49PM +0100, Christoph Hellwig wrote:
> On Tue, Oct 15, 2002 at 05:07:06PM -0700, Greg KH wrote:
> > On Tue, Oct 15, 2002 at 01:28:28PM -0700, Greg KH wrote:
> > > On Tue, Oct 15, 2002 at 01:10:37PM -0700, David S. Miller wrote:
> > > > 
> > > > I will not even look at the networking LSM bits until
> > > > CONFIG_SECURITY=n is available.
> 
> BTW, there's another big issues with LSM:  so far all those hook
> have no user in a mergeable shape.  For all other additions
> there is a strong need to present something mergable but LSM
> doesn't.  IMHO we should require a pointer to a module in mergaable
> shape (i.e. certainly not selinux) for each new hook addition.

Heh, require this, and oops, all of the hooks disappear :)

Seriously, no, I don't agree with this.  SELinux is currently being
audited by a number of different companies (include some Linux distros),
and after that happens, and the code is cleaned up, I think they will
probably want their module merged (but I don't speak for them at all.)

As for the other modules, I think the OWL-based one is good enough right
now, and I have a very simple module that is in the November issue of
Linux Journal that is probably clean enough to merge.

thanks,

greg k-h
