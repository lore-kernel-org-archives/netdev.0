From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Fri, 22 May 2015 05:08:40 -0700
Message-ID: <1432296520.4060.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net>
	 <20150520025428.GA23304@kroah.com>
	 <b5abf7328b22373e4ec18bd6da479431@vittgam.net>
	 <06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net>
	 <d146b8b8a69462ced89a384e6be85b28@vittgam.net>
	 <4cb068397127c2b2baee1f021b014b11@vittgam.net>
	 <da006bc9072931406270f0fdda06045d@vittgam.net>
	 <6056363be65a2c129551518da94bff20@vittgam.net>
	 <87a8wx97er.fsf@x220.int.ebiederm.org>
	 <ff82713d6862786de9784bd3c9c06bfa@vittgam.net>
	 <20150522040453.GC8530@1wt.eu> <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35122 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbEVMIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 08:08:44 -0400
Received: by igbyr2 with SMTP id yr2so33770843igb.0
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 05:08:43 -0700 (PDT)
In-Reply-To: <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-22 at 04:58 -0500, Eric W. Biederman wrote:
> ip_error does not check if in_dev is NULL before dereferencing it.

> 
> Therefore handle this weird case by just dropping the packet if
> !in_dev.  It will result in dropping the packet sooner, and will not
> result in an actual change of behavior.
> 
> Fixes: 251da4130115b ("ipv4: Cache ip_error() routes even when not forwarding.")
> Reported-by: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
> Tested-by: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
