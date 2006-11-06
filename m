From: "Zhao Xiaoming" <xiaoming.nj@gmail.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Mon, 6 Nov 2006 17:03:15 +0800
Message-ID: <f55850a70611060103o1415d6f2x81d6c724320a4c04@mail.gmail.com>
References: <f55850a70611052207j384e1d3flaf40bb9dd74df7c5@mail.gmail.com>
	 <454EE580.5040506@cosmosbay.com>
	 <f55850a70611060010q3ce9d6d2h4026259d688c6db1@mail.gmail.com>
	 <200611060948.43918.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.201]:14545 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1161723AbWKFJDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 04:03:16 -0500
Received: by nz-out-0102.google.com with SMTP id z3so745081nzf
        for <netdev@vger.kernel.org>; Mon, 06 Nov 2006 01:03:16 -0800 (PST)
To: "Eric Dumazet" <dada1@cosmosbay.com>
In-Reply-To: <200611060948.43918.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2006/11/6, Eric Dumazet <dada1@cosmosbay.com>:
>
> Slab:           293952 kB
> So 292 MB used by slab for 2000 sessions.
>
> Expect 600 MB used by slab for 4000 sessions.
>
> So your precious LOWMEM is not gone at all. It *IS* used by SLAB.
>
> You forgot to send
> cat /proc/slabinfo
>
sorry I didn't make myself clear enough. 2000 sessions means 4000
sockets, 2000 for the server, 2000 for the client.
