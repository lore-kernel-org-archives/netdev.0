From: James Morris <jmorris@namei.org>
Subject: Re: [RFC/PATCH 2/2] update sunrpc to use in-kernel sockets API
Date: Tue, 13 Jun 2006 10:07:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606131006250.3553@d.namei>
References: <1150156564.19929.33.camel@w-sridhar2.beaverton.ibm.com>
 <Pine.LNX.4.64.0606122320010.31627@d.namei> <448E42AE.1010901@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:21123 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751133AbWFMOHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 10:07:48 -0400
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <448E42AE.1010901@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Jun 2006, Sridhar Samudrala wrote:

> > > -	sendpage = sock->ops->sendpage ? : sock_no_sendpage;
> > > +	sendpage = kernel_sendpage ? : sock_no_sendpage;
> > >     
> > 
> > This is not equivalent.
> > 
> >   
> Actually, we could make this a simple assignment as we check for
> sock->ops->sendpage in
> kernel_sendpage().
>    sendpage = kernel_sendpage;

No, the code there is setting different values for sendpage depending on 
whether the page is in high memory or not.


- James
-- 
James Morris
<jmorris@namei.org>
