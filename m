From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 2/5] VSOCK: export __vsock_in_bound/connected_table()
Date: Wed, 4 Oct 2017 11:05:53 -0400
Message-ID: <20171004150553.GE3840@stefanha-x1.localdomain>
References: <20171003153943.23159-1-stefanha@redhat.com>
 <20171003153943.23159-3-stefanha@redhat.com>
 <20171003.214617.1472124119367144767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56720 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752403AbdJDPGA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 11:06:00 -0400
Content-Disposition: inline
In-Reply-To: <20171003.214617.1472124119367144767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 09:46:17PM -0700, David Miller wrote:
> From: Stefan Hajnoczi <stefanha@redhat.com>
> Date: Tue,  3 Oct 2017 11:39:40 -0400
> 
> > @@ -250,15 +250,17 @@ static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
> >  	return NULL;
> >  }
> >  
> > -static bool __vsock_in_bound_table(struct vsock_sock *vsk)
> > +bool __vsock_in_bound_table(struct vsock_sock *vsk)
> >  {
> >  	return !list_empty(&vsk->bound_table);
> >  }
> > +EXPORT_SYMBOL_GPL(__vsock_in_bound_table);
> >  
> > -static bool __vsock_in_connected_table(struct vsock_sock *vsk)
> > +bool __vsock_in_connected_table(struct vsock_sock *vsk)
> >  {
> >  	return !list_empty(&vsk->connected_table);
> >  }
> > +EXPORT_SYMBOL_GPL(__vsock_in_connected_table);
> 
> Maybe you can just make these inline helpers in af_vsock.h?

Will fix in v2.
