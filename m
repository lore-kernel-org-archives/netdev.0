From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/3] secid reconciliation-v01: Repost patchset with
 updates
Date: Thu, 24 Aug 2006 15:37:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608241536130.15506@d.namei>
References: <44EDE6EA.1090601@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:10187 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751678AbWHXThK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 15:37:10 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44EDE6EA.1090601@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Aug 2006, Venkat Yekkirala wrote:

> The following are the changes included in this patchset since the previous
> post:
> 
> - Use SELinux transition rules instead of precedence when reconciling the
> secid's
>  making it flexible/policy-driven; xfrm secid would prevail by default.
> - Change the naming of access vector perms to flow_in and flow_out.
> - Make selinux_xfrm_sock_rcv_skb checks conditional on compat_net.
> - Switch selinux_inet_conn_request to use secmark; cipso is still allowed to
>  override secmark currently in this regard (will rely on Paul Moore at HP
>  to bring cipso into the reconciliation path).

I like these changes, but wondering why you haven't supplied code for the 
outbound case ?


- James
-- 
James Morris
<jmorris@namei.org>
