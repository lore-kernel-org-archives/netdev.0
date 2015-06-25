From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: do not bindly dump two families
Date: Wed, 24 Jun 2015 23:32:37 -0400
Message-ID: <20150624233237.3a4a263b@uryu.home.lan>
References: <1432903069.7456.87.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:33965 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbbFYDcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 23:32:41 -0400
Received: by qcji3 with SMTP id i3so17729893qcj.1
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 20:32:41 -0700 (PDT)
In-Reply-To: <1432903069.7456.87.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 May 2015 05:37:49 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> ss currently dumps IPv4 sockets, then IPv6 sockets from the kernel,
> even if -4 or -6 option was given. Filtering in user space then has to
> drop all sockets of wrong family. Such a waste of time...
> 
> Before :
> 
> $ time ss -tn -4 | wc -l
> 251659
> 
> real	0m1.241s
> user	0m0.423s
> sys	0m0.806s
> 
> After:
> 
> $ time ss -tn -4 | wc -l
> 251672
> 
> real	0m0.779s
> user	0m0.412s
> sys	0m0.386s
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I applied all 3 ss patches for the 4.1 release in progress.
