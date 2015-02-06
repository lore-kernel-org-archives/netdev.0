From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Possible data stall with RPS and CPU hotplug
Date: Thu, 05 Feb 2015 16:20:13 -0800
Message-ID: <1423182013.31870.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <90b4251bdb040907ea73f992e1bb96df.squirrel@www.codeaurora.org>
	 <1423012751.907.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <29656169f6b412195cea472d21c89b4f.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:40777 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbbBFAUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:20:15 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so3240159igd.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 16:20:14 -0800 (PST)
In-Reply-To: <29656169f6b412195cea472d21c89b4f.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 23:32 +0000, subashab@codeaurora.org wrote:
> Thanks for the suggestion. It appears to be an oversight on my part that
> the device where the crash was reported did not have commit
> ac64da0b83d82abe62f78b3d0e21cca31aea24fa ("net: rps: fix cpu unplug").

I tried very hard to crash the net-next kernel and I couldn't.

(I got harmless "NOHZ: local_softirq_pending 08" messages only)

But maybe your arch behaves differently in cpu hotplug territory.
