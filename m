From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Fri, 12 Aug 2016 16:08:12 -0700
Message-ID: <20160812230810.GB48651@ast-mbp.thefacebook.com>
References: <20160729064722.GA54517@ast-mbp.thefacebook.com>
 <579B0B9F.8040805@iogearbox.net>
 <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
 <579BF2A1.7000709@iogearbox.net>
 <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
 <20160730053415.GA78880@ast-mbp.thefacebook.com>
 <CALDO+SaVhA4GB+=-LnbZpWyx15wgc8PRFXVD4dO-O5kb+hJE9g@mail.gmail.com>
 <20160801160738.GA99707@ast-mbp.thefacebook.com>
 <CALDO+SbcTh9Gd75wrJRUvo7SG-kCaKDk8fteQKndTz+_NnAccw@mail.gmail.com>
 <CALDO+SbrUBa0JpGTbX2cFs3rVhchPtSOmw=Jwjb26fkQ=w0qmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34565 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbcHLXIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 19:08:17 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so36697pac.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 16:08:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALDO+SbrUBa0JpGTbX2cFs3rVhchPtSOmw=Jwjb26fkQ=w0qmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 09:58:51AM -0700, William Tu wrote:
> Hi,
> 
> I've tested on ESXi version 5.5 and it seems OK.
> - VM1: Ubuntu 14.04, kernel 3.19 ---> OK 3 cpu dirs, possible = 0-2
> - VM2: Centos7, kernel 3.10 ---> OK 8 cpu dirs, possible = 0-7
> 
> I tried another MacBook with Fusion, same issue happens, the cpu[0-9]
> dirs are not equal to /sys/devices/system/cpu/possible

great. thanks for testing. I think the issue is closed and
hopefully you can follow up with fusion guys ;)
