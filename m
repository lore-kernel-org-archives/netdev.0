From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 4/7] secid reconciliation-v03: Invoke LSM hook for outbound
 traffic
Date: Fri, 29 Sep 2006 03:42:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609290338050.1650@d.namei>
References: <451C85E2.2030201@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:48585 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161348AbWI2Hm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:42:59 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <451C85E2.2030201@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006, Venkat Yekkirala wrote:

> +		}
> +		else	/* inbound */
> +			/* loopback traffic should already be labeled
> +			   and any filtering on outbound should suffice */
> +			if (in == &loopback_dev)
> +				goto out;

Minor nit that akpm will point out, the else belongs on the same line as 
the brace.  Also, the comment style is:

	/*
	 * Comment...
	 * etc.
	 */




- James
-- 
James Morris
<jmorris@namei.org>
