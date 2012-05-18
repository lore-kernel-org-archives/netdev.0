From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Fri, 18 May 2012 17:49:36 +0200
Message-ID: <1337356176.7029.47.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337355955.15044.24.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51366 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757200Ab2ERPtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 11:49:45 -0400
Received: by bkcji2 with SMTP id ji2so2468347bkc.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 08:49:44 -0700 (PDT)
In-Reply-To: <1337355955.15044.24.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 16:45 +0100, Kieran Mansley wrote:
> On Thu, 2012-05-17 at 18:37 +0200, Eric Dumazet wrote:
> > 
> > Hmm, I was not suggesting running production servers with this
> > setting, only do an experiment.
> 
> OK.  I've found a more reliable way to reproduce it (use MSG_WAITALL to
> make the recv call wait till the socket buffer will be more full) and
> tried with the tcp_adv_win_scale to -2.  It's hard to make any confident
> assertions about the impact of it, but if it does change the behaviour
> it is a small change.  There are certainly still plenty of drops with
> that setting.

Are you playing with SO_RCVBUF, or let the stack autotune it ?
