From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2 2/3] bridge: only expire the mdb entry when
 query is received
Date: Tue, 30 Apr 2013 12:09:14 +0800
Message-ID: <1367294954.3216.13.camel@cr0>
References: <1367293270-26256-1-git-send-email-amwang@redhat.com>
	 <1367293270-26256-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908Ab3D3EJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 00:09:26 -0400
In-Reply-To: <1367293270-26256-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 11:41 +0800, Cong Wang wrote:
> @@ -1263,13 +1265,16 @@ static void br_multicast_leave_group(struct
> net_bridge *br,
...
>  
> +       if (!mp->timer_armed)
> +               goto out;
> + 

The above piece doesn't look right, will fix it in v3.
