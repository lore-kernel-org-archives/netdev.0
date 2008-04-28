From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix oops in backup for fwmark conn templates
Date: Mon, 28 Apr 2008 18:30:14 +1000
Message-ID: <20080428083011.GA6139@verge.net.au>
References: <Pine.LNX.4.58.0804281028110.2775@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	"Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Wensong Zhang <wensong@linux-vs.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:37717 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765742AbYD1IaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 04:30:23 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0804281028110.2775@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 10:52:38AM +0300, Julian Anastasov wrote:
> 
> 	Fixes bug http://bugzilla.kernel.org/show_bug.cgi?id=10556
> where conn templates with protocol=IPPROTO_IP can oops backup box.
> 
>         Result from ip_vs_proto_get() should be checked because
> protocol value can be invalid or unsupported in backup. But
> for valid message we should not fail for templates which use
> IPPROTO_IP. Also, add checks to validate message limits and
> connection state. Show state NONE for templates using IPPROTO_IP.

Julian, am I right in thinking that this is a long-standing bug
rather than a recent regression?

-- 
Horms

