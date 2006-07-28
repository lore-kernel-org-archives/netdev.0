From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 10/10] MLSXFRM-v02: Auto-labeling of child sockets
Date: Fri, 28 Jul 2006 00:53:30 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607280050590.13981@d.namei>
References: <44BD196C.6000307@trustedcs.com> <44C8EF98.3020507@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:56804 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751942AbWG1Exc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 00:53:32 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44C8EF98.3020507@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jul 2006, Venkat Yekkirala wrote:

> The following patch will fix the build problem (encountered by Andrew Morton)
> when SECURITY_NETWORK_XFRM is not enabled.
> 
> As compared to git-net-selinux_xfrm_decode_session-build-fix.patch in -mm,
> this patch sets the return parameter sid to SECSID_NULL in
> selinux_xfrm_decode_session()
> and handles this value in the caller selinux_inet_conn_request()
> appropriately.
> 
> Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>

Acked-by: James Morris <jmorris@namei.org>

> --- NOTE: Not sure what the ideal thing to do is here. The following is 
> incremental to the original patch. I can send a revision of the entire 
> patch with these changes if desired.

Send it to Andrew Morton saying it replaces

  git-net-selinux_xfrm_decode_session-build-fix.patch

and with any luck, he'll drop the old fix and add this one.



- James
-- 
James Morris
<jmorris@namei.org>
