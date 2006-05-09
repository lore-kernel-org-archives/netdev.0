From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual network device	driver.
Date: Tue, 9 May 2006 16:51:22 -0700
Message-ID: <20060509235122.GJ24291@moss.sous-sol.org>
References: <20060509085201.446830000@sous-sol.org> <E1FdatV-0000lj-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, Christian.Limpach@cl.cam.ac.uk,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	ian.pratt@xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:16003 "EHLO
	sous-sol.org") by vger.kernel.org with ESMTP id S932277AbWEIXsv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 19:48:51 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FdatV-0000lj-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Chris Wright <chrisw@sous-sol.org> wrote:
> >
> > +       netdev->features        = NETIF_F_IP_CSUM;
> 
> Any reason why IP_CSUM was chosen instead of HW_CSUM? Doing the latter
> would seem to be in fact easier for a virtual driver, no?

That, I really don't know.

thanks,
-chris
