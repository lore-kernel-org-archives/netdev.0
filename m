From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [openib-general] [PATCH 02/13] Device Discovery and ULLD
	Linkage
Date: Fri, 17 Nov 2006 11:59:18 -0600
Message-ID: <1163786358.8457.68.camel@stevo-desktop>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>
	 <20061116035837.22635.13571.stgit@dell3.ogc.int>
	 <455DF70C.7090400@pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:941 "EHLO
	smtp.opengridcomputing.com") by vger.kernel.org with ESMTP
	id S933754AbWKQR7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 12:59:19 -0500
To: Bryan O'Sullivan <bos@pathscale.com>
In-Reply-To: <455DF70C.7090400@pathscale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-17 at 09:53 -0800, Bryan O'Sullivan wrote:
> Steve Wise wrote:
> 
> > +static inline void *vzmalloc(int size)
> > +{
> > +	void *p = vmalloc(size);
> > +	memset(p, 0, size);
> > +	return p;
> > +}
> 
> This isn't checking the return value from vmalloc.
> 

Oops...


> Also, we could do with a generic vzalloc and vcalloc, just as we now 
> have kzalloc and kcalloc.  There are lots of routines like this sitting 
> around.
> 
> 	<b

I guess I'll post a kernel patch to add these...



