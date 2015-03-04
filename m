From: Michel Machado <michel@digirati.com.br>
Subject: Re: Linux XIA - merge proposal
Date: Tue, 03 Mar 2015 19:31:58 -0500
Message-ID: <54F6527E.6080406@digirati.com.br>
References: <54F5EF6E.9090303@digirati.com.br> <54F64B75.3010109@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta123.f1.k8.com.br ([187.73.32.199]:38684 "EHLO
	mta123.f1.k8.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757760AbbCDAcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 19:32:07 -0500
In-Reply-To: <54F64B75.3010109@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

>> We're fine with clearly marking Linux XIA as being under staging
>> as well as helping to define this review process for network stacks.
>
> With regard to staging, the code there is usually horrible and I'm
> not sure anyone really looks there, that would mitigate the review
> problem to the time when you try to get it out from there, so I'm
> not sure it brings anything. ;)

    I suggested staging as a way to incrementally review the code. XIA 
is very modular, each component is a kernel module. So one can review a 
kernel module at a time. My intention is to lower the review burden as 
much as I can. I'm open to suggestions to work this out.

> +1 on what Eric said, would have also been nice if you had clearly
> described in your mail (w/o buzz words) what it is and what it does.

    XIA is not an incremental design over IP, and a reasonable 
explanation would've made my e-mail exceeding large. Our wiki has a lot 
content explaining the design as well as demoing it, and I can answer 
questions here, or through another communication medium that you guys 
feel comfortable.

> Are you trying to introduce a new network stack as an alternative
> to the current one, e.g. something like FreeBSD's netgraph?

    I'm trying to introduce a new network stack that enables one to 
implement network designs that are incompatible with IP for a reason or 
another. On top of that, these designs, once ported to Linux XIA, could 
be combined to work together as we tried to highlight in the following demo:

https://github.com/AltraMayor/XIA-for-Linux/wiki/An-exemplifying-demo

    There're a good number of designs in the literature that hasn't seen 
the sun light because they are hard to experiment with since they are 
not compatible with IP. Our hope is to bring these designs to life and 
have a true evaluation of them. That is, we hope that Linux XIA will 
enable the community at large to crowdsource the future Internet. We 
work this vision out in this technical report:

http://www.cs.bu.edu/techreports/pdf/2015-001-linux-xia.pdf

[ ]'s
Michel Machado
