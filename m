From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 1/3] bridge: use the bridge IP addr as
 source addr for querier
Date: Fri, 17 May 2013 10:08:32 +0800
Message-ID: <1368756512.3453.18.camel@cr0>
References: <1368755965-26615-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475Ab3EQCIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 22:08:47 -0400
In-Reply-To: <1368755965-26615-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 09:59 +0800, Cong Wang wrote:
> +static DEVICE_ATTR(multicast_query_zero_source, S_IRUGO | S_IWUSR,
> +		   show_multicast_query_zero_source,
> +		   store_multicast_query_zero_source);

The file name seems ugly, I just noticed there is already a similar one
for ICMP: icmp_errors_use_inbound_ifaddr, so I think
'multicast_query_use_ifaddr' should be better than 
'multicast_query_zero_source'.
