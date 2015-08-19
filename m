From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 04/13] ip_tunnels: add IPv6 addresses to
 ip_tunnel_key
Date: Wed, 19 Aug 2015 18:29:50 +0200
Message-ID: <20150819162950.GD3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <18de52560d526d1a92cc042eb74f9dc7892c50ae.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38647 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbHSQ3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:29:52 -0400
Received: by wicja10 with SMTP id ja10so13271682wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:29:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <18de52560d526d1a92cc042eb74f9dc7892c50ae.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> Add the IPv6 addresses as an union with IPv4 ones. When using IPv4, the
> newly introduced padding after the IPv4 addresses needs to be zeroed out.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v1->v2: Fix incorrect IP_TUNNEL_KEY_IPV4_PAD_LEN calculation, thanks to
> Alexei.


Acked-by: Thomas Graf <tgraf@suug.ch>
