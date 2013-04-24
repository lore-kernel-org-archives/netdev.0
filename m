From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 2/4] net: increase frag hash size
Date: Thu, 25 Apr 2013 02:09:43 +0400
Message-ID: <51785827.1000007@cogentembedded.com>
References: <20130424154624.16883.40974.stgit@dragon> <20130424154822.16883.93014.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:33361 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758459Ab3DXWLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 18:11:00 -0400
Received: by mail-la0-f45.google.com with SMTP id em20so922007lab.4
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 15:10:59 -0700 (PDT)
In-Reply-To: <20130424154822.16883.93014.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-04-2013 19:48, Jesper Dangaard Brouer wrote:

> Increase fragmentation hash bucket size to 1024 from old 64 elems.

> After we increased the frag mem limits (in commit v3.8-rc3-503-gc2a9366)

    This is not a commit ID, commit ID is SHA1 key alone. And you should also 
specify that commit's summary line with it, in parens.

> the hash size of 64 elements is simply too small.  Also considering
> the mem limit is per netns and the hash table is shared for all netns.

> For the embedded people, note that this increase will change the hash
> table/array from using approx 1 Kbytes to 16 Kbytes.

> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

WBR, Sergei
