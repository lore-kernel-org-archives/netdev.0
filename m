From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 04/13] ip_tunnels: add IPv6 addresses to
 ip_tunnel_key
Date: Wed, 19 Aug 2015 11:55:00 -0700
Message-ID: <20150819185459.GA1634@Alexeis-MacBook-Pro-3.local>
References: <cover.1439978875.git.jbenc@redhat.com>
 <18de52560d526d1a92cc042eb74f9dc7892c50ae.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35698 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbHSSzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:55:03 -0400
Received: by pacdd16 with SMTP id dd16so511287pac.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:55:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <18de52560d526d1a92cc042eb74f9dc7892c50ae.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 12:09:54PM +0200, Jiri Benc wrote:
> Add the IPv6 addresses as an union with IPv4 ones. When using IPv4, the
> newly introduced padding after the IPv4 addresses needs to be zeroed out.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v1->v2: Fix incorrect IP_TUNNEL_KEY_IPV4_PAD_LEN calculation, thanks to
> Alexei.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
