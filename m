From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Fri, 4 May 2012 08:31:32 -0700
Message-ID: <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	<CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	<4FA35A3D.8000205@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:48576 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751231Ab2EDPbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 11:31:34 -0400
Received: by ghrr11 with SMTP id r11so2880111ghr.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 08:31:33 -0700 (PDT)
In-Reply-To: <4FA35A3D.8000205@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
> patch) are different: The former works along with rps_sock_flow_table
> whose CPU info is based on recvmsg by the application. But for the tests
> like what I did, there's no application involved.
>
While rps_sock_flow_table is currently only managed by recvmsg, it
still is the general mechanism that maps flows to CPUs for steering.
There should be nothing preventing you from populating and managing
entries in other ways.

Tom

>
> Deng-Cheng
