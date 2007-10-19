From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 13:23:19 -0700
Message-ID: <OFC9CC5B3C.F6B38A10-ON88257379.006F6FDE-88257379.006FE742@us.ibm.com>
References: <4718FAEA.8060304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: brian.haley@hp.com, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47764 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935831AbXJSUXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 16:23:22 -0400
In-Reply-To: <4718FAEA.8060304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        From looking at the code, it appears that validate
source is failing just because of the rp_filter. Do you have
rp_filter set to nonzero?
        If so, it may do what you want just by setting that
to 0:

sysctl -w net.ipv4.conf.all.rp_filter=0

                                        +-DLS

