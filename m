From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] xfrm: fix XFRMA_MARK extraction in xfrm_mark_get
Date: Wed, 30 Jun 2010 06:07:25 -0400
Message-ID: <1277892445.3509.2.camel@bigi>
References: <4C2AF8EE.8030508@strongswan.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: Andreas Steffen <andreas.steffen@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42910 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab0F3KHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 06:07:30 -0400
Received: by vws5 with SMTP id 5so788107vws.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 03:07:29 -0700 (PDT)
In-Reply-To: <4C2AF8EE.8030508@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 09:57 +0200, Andreas Steffen wrote:
> Determine the size of the xfrm_mark struct, not of its pointer.
> 
> Signed-off-by: Andreas Steffen <andreas.steffen@strongswan.org>

Good catch (you are right this was tested on 64 bit ;->).
The preferred style would be what Simon mentioned. No biggie if
you keep it this way - but if you resubmit, add:
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal


