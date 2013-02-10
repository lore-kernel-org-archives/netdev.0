From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v3 08/11] tbf: fix value set for q->ptokens
Date: Sun, 10 Feb 2013 00:21:38 -0800
Message-ID: <1360484498.20362.12.camel@edumazet-glaptop>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
	 <1360428312-1277-9-git-send-email-jiri@resnulli.us>
	 <1360459846.20362.2.camel@edumazet-glaptop>
	 <20130210081824.GA1570@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:57613 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab3BJIVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 03:21:41 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so2337472dak.2
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 00:21:40 -0800 (PST)
In-Reply-To: <20130210081824.GA1570@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-02-10 at 09:18 +0100, Jiri Pirko wrote:
> Sun, Feb 10, 2013 at 02:30:46AM CET, eric.dumazet@gmail.com wrote:
> >On Sat, 2013-02-09 at 17:45 +0100, Jiri Pirko wrote:
> >> q->ptokens is in ns and we are assigning q->mtu directly to it. That is
> >> wrong. psched_l2t_ns() should be used to compute correct value.
> >> 
> >
> >
> >Not clear why its a separate patch, and not folded in the 6th
> 
> This is independent on 6th. Would be needed even if 6th wouldn't be
> there.

When was this bug introduced then ?
