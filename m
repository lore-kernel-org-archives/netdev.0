From: Michel Machado <michel@digirati.com.br>
Subject: Re: include/linux/netlink.h: problem when included by an
 application
Date: Sun, 07 Aug 2011 18:14:23 -0400
Message-ID: <1312755263.2908.6.camel@Thor>
References: <1312580748.2326.15.camel@Thor>
	 <1312679707.2591.987.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta63.f1.k8.com.br ([187.16.23.95]:56448 "EHLO
	mta63.f1.k8.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393Ab1HGWOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2011 18:14:31 -0400
In-Reply-To: <1312679707.2591.987.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >    The simplest solution that I came up was replacing sa_family_t in
> > include/linux/netlink.h to 'unsigned short' as header
> > include/linux/socket.h does for struct __kernel_sockaddr_storage
> > available to applications.
> 
> Maybe we should do something like this in <linux/socket.h>:
> 
> typedef unsigned short __kernel_sa_family_t;
> #ifdef __KERNEL__
> typedef __kernel_sa_family_t sa_family_t;
> #endif
> 
> and then use __kernel_sa_family_t in <linux/netlink.h>.
> 
> Ben.

   I like this solution, it solves both struct __kernel_sockaddr_storage
in include/linux/socket.h, and struct sockaddr_nl in
include/linux/netlink.h.

[ ]'s
Michel Machado

