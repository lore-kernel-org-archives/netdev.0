From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/2] net: fix compat_sys_recvmmsg parameter type
Date: Thu, 10 Dec 2009 10:47:06 -0200
Message-ID: <20091210124706.GB20963@ghostprotocols.net>
References: <20091210065815.GA4144@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34933 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758115AbZLJMrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 07:47:04 -0500
Content-Disposition: inline
In-Reply-To: <20091210065815.GA4144@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 10, 2009 at 07:58:16AM +0100, Heiko Carstens escreveu:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> compat_sys_recvmmsg has a compat_timespec parameter and not a
> timespec parameter. This way we also get rid of an odd cast.
> 
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Was unaware of this helper, thanks!

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
