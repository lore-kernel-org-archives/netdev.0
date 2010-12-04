From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 22:20:52 +0800
Message-ID: <AANLkTinLaWCB1c-i6_uVqovu_Fa3dSCRK4Y=_KPvyvrF@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <1291472282.2159.8.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56741 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114Ab0LDOm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:42:57 -0500
Received: by fxm20 with SMTP id 20so3050459fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:42:56 -0800 (PST)
In-Reply-To: <1291472282.2159.8.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 10:18 PM, jamal <hadi@cyberus.ca> wrote:
>
> I like the splice idea but this patch makes me twitch
> a little. What test setup did you use to check it?
>

Just a simple test:

tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff: protocol ip basic action mirred
egress redirect dev ifb0

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
