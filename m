From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipvs: fix oops in backup for fwmark conn templates
Date: Tue, 29 Apr 2008 03:21:52 -0700 (PDT)
Message-ID: <20080429.032152.137995014.davem@davemloft.net>
References: <Pine.LNX.4.58.0804281028110.2775@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, rumen@voicecho.com,
	wensong@linux-vs.org, horms@verge.net.au
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753216AbYD2KVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:21:53 -0400
In-Reply-To: <Pine.LNX.4.58.0804281028110.2775@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 28 Apr 2008 10:52:38 +0300 (EEST)

> 
> 	Fixes bug http://bugzilla.kernel.org/show_bug.cgi?id=10556
> where conn templates with protocol=IPPROTO_IP can oops backup box.
> 
>         Result from ip_vs_proto_get() should be checked because
> protocol value can be invalid or unsupported in backup. But
> for valid message we should not fail for templates which use
> IPPROTO_IP. Also, add checks to validate message limits and
> connection state. Show state NONE for templates using IPPROTO_IP.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I'm applying this to mainline, thanks Julian.

After the patch gets some more exposure and testing we can
push it to -stable.
