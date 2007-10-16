From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
Date: Tue, 16 Oct 2007 09:22:31 -0400
Message-ID: <1192540951.4480.108.camel@localhost>
References: <1192537921.4480.80.camel@localhost>
	 <4714B445.1020900@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:56190 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932210AbXJPN0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 09:26:47 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2379419wah
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 06:26:46 -0700 (PDT)
In-Reply-To: <4714B445.1020900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-16-10 at 14:53 +0200, Patrick McHardy wrote:
> jamal wrote:
> 
> [Can't quote for some reason ..]

Sorry, trying to be clever with git-format-patch but chickened out
sending using git-am - so patch was just attached (Dave seems to be 
friendly to such an approach when he applies)

> I don't think this change is safe since we might loose the
> redirect counter and have endless redirect loops. ipip for
> example calls skb_realloc_headroom, which clones the skb
> when delta > 0, so it seems we really need to copy tc_verd
> in skb_clone(). Generally the assumption that drivers don't
> clone packets doesn't seem safe.

Does the copying of tc_verd in __copy_skb_header() not cover that?

cheers,
jamal


