From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: rename ip lwtunnel attributes
Date: Mon, 17 Aug 2015 14:07:38 -0700 (PDT)
Message-ID: <20150817.140738.322659099882412395.davem@davemloft.net>
References: <f6abe6522e88ea21d2ccf6e50f9e563fdf8f3a37.1439563196.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbHQVHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:07:39 -0400
In-Reply-To: <f6abe6522e88ea21d2ccf6e50f9e563fdf8f3a37.1439563196.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 14 Aug 2015 16:40:40 +0200

> We already have IFLA_IPTUN_ netlink attributes. The IP_TUN_ attributes look
> very similar, yet they serve very different purpose. This is confusing for
> anyone trying to implement a user space tool supporting lwt.
> 
> As the IP_TUN_ attributes are used only for the lightweight tunnels, prefix
> them with LWTUNNEL_IP_ instead to make their purpose clear. Also, it's more
> logical to have them in lwtunnel.h together with the encap enum.
> 
> Fixes: 3093fbe7ff4b ("route: Per route IP tunnel metadata via lightweight tunnel")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> These are still in net-next only, thus it's safe to change them.
> 
> It's still a bit weird these attributes are in RTA_ENCAP, perhaps we should
> also rename RTA_ENCAP to RTA_LWT_ENCAP or similar?

Applied, thanks.
