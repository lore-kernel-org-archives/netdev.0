From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] change format of LSM hooks
Date: Thu, 17 Oct 2002 14:21:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017142149.A23181@infradead.org>
References: <20021015194545.GC15864@kroah.com> <20021015.124502.130514745.davem@redhat.com> <20021015201209.GE15864@kroah.com> <20021015.131037.96602290.davem@redhat.com> <20021015202828.GG15864@kroah.com> <20021016000706.GI16966@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, becker@scyld.com,
   jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-security-module@wirex.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20021016000706.GI16966@kroah.com>; from greg@kroah.com on Tue, Oct 15, 2002 at 05:07:06PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2002 at 05:07:06PM -0700, Greg KH wrote:
> On Tue, Oct 15, 2002 at 01:28:28PM -0700, Greg KH wrote:
> > On Tue, Oct 15, 2002 at 01:10:37PM -0700, David S. Miller wrote:
> > > 
> > > I will not even look at the networking LSM bits until
> > > CONFIG_SECURITY=n is available.

BTW, there's another big issues with LSM:  so far all those hook
have no user in a mergeable shape.  For all other additions
there is a strong need to present something mergable but LSM
doesn't.  IMHO we should require a pointer to a module in mergaable
shape (i.e. certainly not selinux) for each new hook addition.
