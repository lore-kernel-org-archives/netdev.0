From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 02:35:15 -0700 (PDT)
Message-ID: <20071010.023515.15263796.davem@davemloft.net>
References: <20071010085530.GA7532@iris.sw.ru>
	<m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org
To: aarapov@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbXJJJfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:35:12 -0400
In-Reply-To: <m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Arapov <aarapov@redhat.com>
Date: Wed, 10 Oct 2007 11:00:17 +0200

> Ok, I've got it, so we have to do the same with the following:
> quote from inet_hashtables.c and inet6_hashtables.c. I'll prepare the
> patch.
> 
> And just a curious, does the /* Treat low > high as high == low */
> idea will keep after the sysctl will be patched?

I'm beginning to think that we should do the sysctl validation
in this patch too, instead of duplicating this grotty check
in all of these port selection functions.
