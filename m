From: James Morris <jmorris@namei.org>
Subject: Re: [RFC/PATCH 2/2] update sunrpc to use in-kernel sockets API
Date: Mon, 12 Jun 2006 23:25:48 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606122320010.31627@d.namei>
References: <1150156564.19929.33.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:49356 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1752256AbWFMDZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 23:25:51 -0400
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1150156564.19929.33.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Jun 2006, Sridhar Samudrala wrote:

> -	sendpage = sock->ops->sendpage ? : sock_no_sendpage;
> +	sendpage = kernel_sendpage ? : sock_no_sendpage;

This is not equivalent.


-- 
James Morris
<jmorris@namei.org>
