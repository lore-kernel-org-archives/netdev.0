From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/2] ipv4: send arp replies to the correct tunnel
Date: Wed, 23 Sep 2015 10:10:21 +0200
Message-ID: <20150923081021.GC29680@pox.localdomain>
References: <cover.1442936392.git.jbenc@redhat.com>
 <cd7f171ada2f0933687fd2a987885aa9af7a7f9c.1442936392.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:32789 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbbIWIKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 04:10:24 -0400
Received: by wiclk2 with SMTP id lk2so227069659wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 01:10:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cd7f171ada2f0933687fd2a987885aa9af7a7f9c.1442936392.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/15 at 06:12pm, Jiri Benc wrote:
> When using ip lwtunnels, the additional data for xmit (basically, the actual
> tunnel to use) are carried in ip_tunnel_info either in dst->lwtstate or in
> metadata dst. When replying to ARP requests, we need to send the reply to
> the same tunnel the request came from. This means we need to construct
> proper metadata dst for ARP replies.
> 
> We could perform another route lookup to get a dst entry with the correct
> lwtstate. However, this won't always ensure that the outgoing tunnel is the
> same as the incoming one, and it won't work anyway for IPv4 duplicate
> address detection.
> 
> The only thing to do is to "reverse" the ip_tunnel_info.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Great start, thanks!

Acked-by: Thomas Graf <tgraf@suug.ch>
