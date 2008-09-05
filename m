From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 09/14] netlabel: Add functionality to set the
 security attributes of a packet
Date: Fri, 5 Sep 2008 19:03:21 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051902050.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903004947.15669.68884.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:39920 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbYIEJDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 05:03:24 -0400
In-Reply-To: <20080903004947.15669.68884.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Sep 2008, Paul Moore wrote:

> --- a/security/selinux/include/objsec.h
> +++ b/security/selinux/include/objsec.h
> @@ -117,6 +117,7 @@ struct sk_security_struct {
>  		NLBL_UNSET = 0,
>  		NLBL_REQUIRE,
>  		NLBL_LABELED,
> +		NLBL_REQSKB
>  	} nlbl_state;
>  #endif
>  };

Might be nice to include a comma after that if you update the patches.


Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
