From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/3][NETLABEL]: Compilation for CONFIG_AUDIT=n case.
Date: Wed, 13 Feb 2008 12:21:16 -0500
Message-ID: <200802131221.16929.paul.moore@hp.com>
References: <47AB3DDE.8050109@openvz.org> <20080212.223544.21007139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:35816 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbYBMRVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 12:21:22 -0500
In-Reply-To: <20080212.223544.21007139.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 February 2008 1:35:44 am David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Thu, 07 Feb 2008 20:20:30 +0300
>
> > The audit_log_start() will expand into an empty do { } while (0)
> > construction and the audit_ctx becomes unused.
> >
> > The solution: push current->audit_context into audit_log_start()
> > directly, since it is not required in any other place in the
> > calling function.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
> Applied.

Sorry I missed these three patches when they were posted because my 
email got screwy and I was dropped from netdev (all of vger.kernel.org 
actually).  I just dug them up in the archives and they looks fine to 
me.  Thanks again Pavel.

(better late than never I suppose, applies to all three patches in the 
patchset)

Acked-by: Paul Moore <paul.moore@hp.com>

-- 
paul moore
linux security @ hp
