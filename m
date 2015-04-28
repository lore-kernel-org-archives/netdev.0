From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 14:21:08 +0300
Message-ID: <20150428112108.GA22108@angus-think.wlc.globallogic.com>
References: <553EE0D9.3050601@ionic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mihai Moldovan <ionic@ionic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:36705 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965450AbbD1LVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 07:21:30 -0400
Received: by lagv1 with SMTP id v1so101667451lag.3
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 04:21:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <553EE0D9.3050601@ionic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 03:22:33AM +0200, Mihai Moldovan wrote:
> Hi,
> 
> Following up a bug report I received at
> http://bugs.x2go.org/cgi-bin/bugreport.cgi?bug=799 it looks like the current
> version iproute2's ss utility always returns an empty result set whenever
> specifying the -u flag.
> 
> The problem has been bisected to 9db7bf15e22b6a1b8bc09c4a1e29571cbca55c94 and is
> also affecting version 3.19.0, but most notably 4.0.0+.
> 
> I'm not quite sure that's the correct commit, but it does definitely look related.
> 
> Even ss -xu, which previously returned a list of UNIX and UDP sockets now
> returns nothing on my systems.
> 
> 
> Any help with that matter is greatly appreciated.
> 
> 
> 
> Mihai
> 


Hi Mihai,

Seems I have a fixed version, I tested it localy with different
option combinations, and now there should be no issues when specifying
different families.

Would you be able to test it ? How I can provide a fixed version to you -
by patch or I can push to my github and give you a link ?

Thanks,
