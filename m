From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] minor socket ioctl cleanup for 2.5.30
Date: Fri, 9 Aug 2002 03:46:05 +1000 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0208090342500.20104-100000@blackbird.intercode.com.au>
References: <20020808184206.Q24631@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20020808184206.Q24631@parcelfarce.linux.theplanet.co.uk>
List-Id: netdev.vger.kernel.org

On Thu, 8 Aug 2002, Matthew Wilcox wrote:

> this patch is for information purposes only, right?  ;-)

Yes.

> > +long f_getown(struct file *filp)
> > +{
> > +	return filp->f_owner.pid;
> > +}
> 
> i still think this function shouldn't exist -- a direct reference is
> no problem.

Agreed.

> 
> 
> > +			f_setown(filp, arg);

> this is now hooked by the LSM folks so patch will need to be updated for
> 2.5.30.

Yep, a more recent version of this patch consolidates the LSM 
file_set_fowner hook into f_setown().


- James
-- 
James Morris
<jmorris@intercode.com.au>
