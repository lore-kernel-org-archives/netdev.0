From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] lwtunnel: rename ip lwtunnel attributes
Date: Fri, 14 Aug 2015 18:51:07 +0200
Message-ID: <20150814165107.GA6431@pox.localdomain>
References: <f6abe6522e88ea21d2ccf6e50f9e563fdf8f3a37.1439563196.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33810 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352AbbHNQvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 12:51:10 -0400
Received: by wicne3 with SMTP id ne3so25303016wic.1
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 09:51:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f6abe6522e88ea21d2ccf6e50f9e563fdf8f3a37.1439563196.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/15 at 04:40pm, Jiri Benc wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>

> ---
> These are still in net-next only, thus it's safe to change them.
> 
> It's still a bit weird these attributes are in RTA_ENCAP, perhaps we should
> also rename RTA_ENCAP to RTA_LWT_ENCAP or similar?

I think RTA_ENCAP is fine but I don't mind changing it either.
