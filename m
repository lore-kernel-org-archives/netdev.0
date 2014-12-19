From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Fri, 19 Dec 2014 12:11:44 +0100
Message-ID: <20141219121144.5f9899ba@griffin>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, Stefan Assmann <sassmann@redhat.com>
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbaLSLMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 06:12:00 -0500
In-Reply-To: <1418898522-13588-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 15:58:42 +0530, Govindarajulu Varadarajan wrote:
> Hardware always provides compliment of IP pseudo checksum. Stack expects
> whole packet checksum without pseudo checksum if CHECKSUM_COMPLETE is set.
> 
> This causes checksum error in nf & ovs.
> 
> [...]
> 
> Hardware verifies IP & tcp/udp header checksum but does not provide payload
> checksum, use CHECKSUM_UNNECESSARY. Set it only if its valid IP tcp/udp packet.
> 
> Cc: Jiri Benc <jbenc@redhat.com>
> Cc: Stefan Assmann <sassmann@redhat.com>
> Reported-by: Sunil Choudhary <schoudha@redhat.com>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Reviewed-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
