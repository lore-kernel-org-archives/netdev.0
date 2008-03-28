From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/11 net-2.6.26] [DCCP]: dccp_v(4|6)_ctl_socket is
	leaked.
Date: Fri, 28 Mar 2008 13:47:52 -0300
Message-ID: <20080328164752.GX14945@ghostprotocols.net>
References: <1206695071.3271.8.camel@iris.sw.ru> <1206695338-5947-3-git-send-email-den@openvz.org> <20080328144446.GU14945@ghostprotocols.net> <1206717778.4294.4.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbYC1QsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 12:48:05 -0400
Content-Disposition: inline
In-Reply-To: <1206717778.4294.4.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 28, 2008 at 06:22:58PM +0300, Denis V. Lunev escreveu:
> On Fri, 2008-03-28 at 11:44 -0300, Arnaldo Carvalho de Melo wrote:
> > Em Fri, Mar 28, 2008 at 12:08:50PM +0300, Denis V. Lunev escreveu:
> > > This seems a purism as module can't be unloaded, but though if cleanup method
> > > is present it should be correct and clean all staff created.
> > 
> > Its the right thing to do :-) But perhaps we could have a
> > inet_csk_ctl_sock_destroy() as we have inet_csk_ctl_sock_create?
> > 
> > And since this is not csk at all, could you please rename it to
> > inet_ctl_sock_{create,destroy}()? I Agree with Vlad and Pavel that this
> > would make it more clear, as SCTP is not (yet) a inet_connection_sock.
> 
> Basically, after these sockets will be moved into namespace we'll use
> sk_release_kernel for them.
> 
> Can I send a rename as a follow up on Monday :) ?

Logically the rename should be done first, then its use, but its up to
Dave/you.

- Arnaldo
