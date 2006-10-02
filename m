From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/9] secid reconciliation-v04: Enforcement for SELinux
Date: Mon, 2 Oct 2006 12:43:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610021242330.11172@d.namei>
References: <452032A6.1080306@trustedcs.com>  <45213A55.8070205@hp.com>
 <1159806908.6855.58.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:51944 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965085AbWJBQnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 12:43:41 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <1159806908.6855.58.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2006, Stephen Smalley wrote:

> It appears that selinux_xfrm_decode_session() can only legitimately
> return an error if the last argument (ckall) is non-zero.
> security_skb_classify_flow() was doing the same thing prior to this
> patch series.  It would be clearer if there were two separate interfaces
> that internally use the same helper, with one of the functions returning
> void.

Ok, this can be a followup patch request (and not block merging).

- James
-- 
James Morris
<jmorris@namei.org>
