From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 2/5] xen-netback: add support for IPv6
 checksum offload from guest
Date: Mon, 14 Oct 2013 11:42:35 +0100
Message-ID: <20131014104235.GB11739@zion.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
 <1381503982-1418-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:30153 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951Ab3JNKq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 06:46:57 -0400
Content-Disposition: inline
In-Reply-To: <1381503982-1418-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 04:06:19PM +0100, Paul Durrant wrote:
[...]
> -/*
> - * This is the amount of packet we copy rather than map, so that the
> - * guest can't fiddle with the contents of the headers while we do
> - * packet processing on them (netfilter, routing, etc).
> +/* This is a miniumum size for the linear area to avoid lots of
> + * calls to __pskb_pull_tail() as we set up checksum offsets.
>   */

You seem to forget to explain why 128 is chosen. :-)

Wei.
