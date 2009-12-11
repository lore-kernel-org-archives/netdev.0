From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fix compat_sys_recvmmsg parameter type
Date: Fri, 11 Dec 2009 15:16:38 -0800 (PST)
Message-ID: <20091211.151638.186494261.davem@davemloft.net>
References: <20091210065815.GA4144@osiris.boeblingen.de.ibm.com>
	<20091210124706.GB20963@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40620
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762354AbZLKXQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:16:32 -0500
In-Reply-To: <20091210124706.GB20963@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 10 Dec 2009 10:47:06 -0200

> Em Thu, Dec 10, 2009 at 07:58:16AM +0100, Heiko Carstens escreveu:
>> From: Heiko Carstens <heiko.carstens@de.ibm.com>
>> 
>> compat_sys_recvmmsg has a compat_timespec parameter and not a
>> timespec parameter. This way we also get rid of an odd cast.
>> 
>> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
>> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Was unaware of this helper, thanks!
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
