From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Tue, 11 Apr 2017 13:26:39 +0200
Message-ID: <1491909999.31620.23.camel@sipsolutions.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
                 <58ECB8CF.8040409@iogearbox.net>
         <1491909330.31620.21.camel@sipsolutions.net>
         <58ECBC80.1050009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49678 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751921AbdDKL0l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:26:41 -0400
In-Reply-To: <58ECBC80.1050009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Yeah, you shouldn't need anything special. 

I did add that, yes.

> In case the wifi progs have their own BPF program type, I wouldn't
> even add it to may_access_skb() to not further encourage LD_ABS/IND
> usage. F.e. lwt BPF programs are not hooked up there either.

Interesting, ok. I still need to hook up get_func_proto though to
actually be able to access that.

johannes
