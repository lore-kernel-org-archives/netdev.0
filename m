From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 18:36:42 +0100
Message-ID: <20061110173642.GL8693@postel.suug.ch>
References: <45541757.90800@hp.com> <20061110132450.GA4307@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:1256 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161890AbWKJRgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 12:36:21 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20061110132450.GA4307@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jarek Poplawski <jarkao2@o2.pl> 2006-11-10 14:24
> @@ -449,7 +449,7 @@
>  
>  The second step is to define the operations for the family, which we do by
>  creating at least one instance of the genl_ops structure which we explained in
> -section 3.1.2..  In this example we are only going to define one operation but
> +section 3.1.2.  In this example we are only going to define one operation but
>  you can define up to 255 unique operations for each family.
>  
>    /* handler */
> @@ -465,7 +465,7 @@
>          DOC_EXMPL_C_ECHO,
>          __DOC_EXMPL_C_ECHO,

Careful, the typo is here, not below.

>    };
> -  #define DOC_EXMPL_C_MAX (__DOC_EXMPL_C_MAX - 1)
> +  #define DOC_EXMPL_C_MAX (__DOC_EXMPL_C_ECHO - 1)
>  
>    /* operation definition */
>    struct genl_ops doc_exmpl_gnl_ops_echo = {
