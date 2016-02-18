From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [PATCH net-next] vxlan: tun_id is 64bit, not 32bit
Date: Thu, 18 Feb 2016 16:36:38 -0200
Message-ID: <20160218183638.GP18570@indiana.gru.redhat.com>
References: <7fe6a16a4d1170ed72b7d5c36ca5e4fc4ee54488.1455819507.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paolo Abeni <pabeni@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426516AbcBRSgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 13:36:43 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 520911E2F
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 18:36:43 +0000 (UTC)
Content-Disposition: inline
In-Reply-To: <7fe6a16a4d1170ed72b7d5c36ca5e4fc4ee54488.1455819507.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 07:19:29PM +0100, Jiri Benc wrote:
> The tun_id field in struct ip_tunnel_key is __be64, not __be32. We need to
> convert the vni to tun_id correctly.
> 
> Fixes: 54bfd872bf16 ("vxlan: keep flags and vni in network byte order")
> Reported-by: Paolo Abeni <pabeni@redhat.com>
> Tested-by: Paolo Abeni <pabeni@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
