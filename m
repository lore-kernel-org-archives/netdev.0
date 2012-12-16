From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Sun, 16 Dec 2012 13:05:29 -0500
Message-ID: <50CE0D69.2030608@mojatatu.com>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr> <1355617968-26138-1-git-send-email-jengelh@inai.de> <50CDA2DA.3060805@mojatatu.com> <50CDFEFB.2070208@mojatatu.com> <alpine.LNX.2.01.1212161841070.27614@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, vapier@gentoo.org,
	netdev@vger.kernel.org, urykhy@gmail.com, shemonc@gmail.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:62730 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab2LPSFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 13:05:32 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so8249970ieb.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 10:05:31 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1212161841070.27614@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-16 12:43 PM, Jan Engelhardt wrote:
> On Sunday 2012-12-16 18:03, Jamal Hadi Salim wrote:
>

>
> I saw the same during make, _but_, on running `ldd tc/m_xt.so`, I got a
> libxtables.so entry, so I thought I was fine.
>

Sorry, you are right. Without your patch that doesnt happen. I had 
removed the global dlopen while debugging, so it was using the wrong
m_xt.so

So my Ack is back on;->

cheers,
jamal
