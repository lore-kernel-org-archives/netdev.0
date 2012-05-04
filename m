From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Fri, 04 May 2012 17:47:28 +0200
Message-ID: <1336146448.3752.349.camel@edumazet-glaptop>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	 <4FA35A3D.8000205@mips.com>
	 <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Deng-Cheng Zhu <dczhu@mips.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56054 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab2EDPrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 11:47:46 -0400
Received: by bkcji2 with SMTP id ji2so2329970bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 08:47:44 -0700 (PDT)
In-Reply-To: <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 08:31 -0700, Tom Herbert wrote:
> > I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
> > patch) are different: The former works along with rps_sock_flow_table
> > whose CPU info is based on recvmsg by the application. But for the tests
> > like what I did, there's no application involved.
> >
> While rps_sock_flow_table is currently only managed by recvmsg, it
> still is the general mechanism that maps flows to CPUs for steering.
> There should be nothing preventing you from populating and managing
> entries in other ways.

It might be done from a netfilter module, activated in FORWARD chain for
example.
