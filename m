From: Djalal Harouni <tixxdz@opendz.org>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Mon, 26 Mar 2012 23:42:26 +0100
Message-ID: <20120326224226.GA29626@dztty>
References: <20120326222359.GB28123@dztty>
 <20120326.182411.41401140080225401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from numidia.opendz.org ([98.142.220.152]:55345 "EHLO
	numidia.opendz.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237Ab2CZWir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 18:38:47 -0400
Content-Disposition: inline
In-Reply-To: <20120326.182411.41401140080225401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 06:24:11PM -0400, David Miller wrote:
> From: Djalal Harouni <tixxdz@opendz.org>
> Date: Mon, 26 Mar 2012 23:23:59 +0100
> 
> > +static struct ctl_table_header *ip4_base;
> > +
> >  /*
> >   * We really need to sanitize the damn ipv4 init order, then all
> >   * this nonsense will go away.
> >   */
> > -void __init ip_static_sysctl_init(void)
> > +int __init ip_static_sysctl_init(void)
> >  {
> > -	register_sysctl_paths(ipv4_path, ipv4_skeleton);
> > +	ip4_base = register_sysctl_paths(ipv4_path, ipv4_skeleton);
> 
> This is so incredibly stupid, just panic() or similar if this
> returns NULL.
> 
> And find another way to annotate this for memleak so we don't need to
> waste an entire pointer, which is never used, in the data section.
Ok, thank you.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
tixxdz
http://opendz.org
