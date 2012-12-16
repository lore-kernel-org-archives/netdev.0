From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 13:59:16 -0500
Message-ID: <50CE1A04.1000405@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Hasan Chowdhury <shemonc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:49553 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab2LPS7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 13:59:18 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so8281975ieb.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 10:59:18 -0800 (PST)
In-Reply-To: <50CDFB6A.3090806@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hasan,

I can confirm that xtables_options_xfrm() works.
Just suspicious of that call, "xfrm" seems too specific to xfrm
subsystem but generic enough.
Dont bother resending the patch, it works right now, I am just
waiting for confirmation from Pablo/Jan and i will proceed from there.

I am also still struggling with whether to add your intermediate
solution to rename the xt->ipt.
I think i will go ahead and add a kernel change.

cheers,
jamal
