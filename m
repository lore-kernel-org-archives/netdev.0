From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] tg3: Allow for receive of full-size 8021AD frames
Date: Fri, 19 Sep 2014 16:37:42 -0700
Message-ID: <1411169862.26859.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
	 <1411165389-21276-3-git-send-email-vyasevic@redhat.com>
	 <1411167552.26859.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411168475.6401.37.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Michael Chan <mchan@broadcom.com>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38171 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbaISXhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 19:37:45 -0400
Received: by mail-pd0-f181.google.com with SMTP id r10so818860pdi.26
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 16:37:44 -0700 (PDT)
In-Reply-To: <1411168475.6401.37.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 16:14 -0700, Prashant Sreedharan wrote:

> The NIC will not receive frames of size > mtu + ETH_HLEN + VLAN_HLEN it
> will update the oversize_frame count and drop it. The check is to make
> sure the additional 4 bytes is due to a valid vlan header.

I see, thanks for the explanation ;)
