From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] tcp: listener refactor part 16
Date: Tue, 24 Mar 2015 14:28:48 -0700
Message-ID: <1427232528.25985.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427171666-30585-1-git-send-email-edumazet@google.com>
	 <20150324.150257.1215806444155190560.davem@davemloft.net>
	 <20150324.151439.133059567496002449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34643 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbCXV2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 17:28:50 -0400
Received: by iedfl3 with SMTP id fl3so9401541ied.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 14:28:49 -0700 (PDT)
In-Reply-To: <20150324.151439.133059567496002449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-24 at 15:14 -0400, David Miller wrote:

> Actually, I have to back this out.
> 
> You can't mark all of these things const, because of lockdep:

Arg, sorry for that. I had LOCKDEP enabled, but not CONFIG_PROVE_RCU=y

Will send a v2
