From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net-next] inetpeer: get rid of ip_id_count
Date: Mon, 02 Jun 2014 05:17:36 -0700
Message-ID: <1401711456.3645.182.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401668284.3645.165.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140601.190147.889157989845313443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38348 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbaFBMRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 08:17:39 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so3237526igb.11
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 05:17:38 -0700 (PDT)
In-Reply-To: <20140601.190147.889157989845313443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-01 at 19:01 -0700, David Miller wrote:

> I like it.

Great ;)

> 
> I think we should get rid of the 'dst' argument from __ip_select_ident() (and thus
> ip_select_ident() and ip_select_ident_mode()), it is completely unused.

Sure, I did that, and also renamed ip_select_ident_more() to avoid
decrement number of segs in caller in increment it in
__ip_select_ident() again.

> 
> It might even help to do so for ipv6_select_ident(), having it just pass the
> dest addr pointer in instead.

I added a new helper to perform the id reservation in one place only.

Thanks !
