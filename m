From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/1] tun: TUNGETIFF interface to query name and flags
Date: Thu, 14 Aug 2008 11:58:57 +1000
Message-ID: <200808141158.57879.rusty@rustcorp.com.au>
References: <1218637816.29159.31.camel@muff>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	netdev <netdev@vger.kernel.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:32839 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbYHNEO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 00:14:56 -0400
In-Reply-To: <1218637816.29159.31.camel@muff>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 14 August 2008 00:30:16 Mark McLoughlin wrote:
> A very simple approach is attached; I did consider doing a TUNGETFLAGS
> that would return tun->flags, but I think it's nicer to have a companion
> to TUNGETIFF since it also allows one to query the interface name from
> the file descriptor.

This seems really sensible to me.

If Max acks it, I'd say Dave should merge it.
Rusty.
