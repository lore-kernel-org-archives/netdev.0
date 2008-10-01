From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 12/16] selinux: Set socket NetLabel based on
 connection endpoint
Date: Wed, 1 Oct 2008 20:00:25 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011958380.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125709.17132.47022.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:42251 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbYJAKA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 06:00:27 -0400
In-Reply-To: <20080916125709.17132.47022.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2008, Paul Moore wrote:

>  /**
> + * cipso_v4_sock_delattr - Delete the CIPSO option from a socket
> + * @sk: the socket
> + *
> + * Description:
> + * Removes the CIPSO option from a socket, if present.
> + *
> + */
> +void cipso_v4_sock_delattr(struct sock *sk)

Reviewed-by: James Morris <jmorris@namei.org>


Btw, what kind of testing has this patch had?



- James
-- 
James Morris
<jmorris@namei.org>
