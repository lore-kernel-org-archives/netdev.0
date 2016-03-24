From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 11:32:20 -0700
Message-ID: <1458844340.12033.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20151221204127.GC8018@1wt.eu>
	 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	 <20160324061222.GA6807@1wt.eu>
	 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324142222.GB7237@1wt.eu>
	 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324153053.GA7569@1wt.eu>
	 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324165047.GA7585@1wt.eu>
	 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324180011.GB7585@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33096 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbcCXScX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:32:23 -0400
Received: by mail-pf0-f175.google.com with SMTP id 4so64629877pfd.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:32:22 -0700 (PDT)
In-Reply-To: <20160324180011.GB7585@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 19:00 +0100, Willy Tarreau wrote:

> OK so this means we have to find a way to expand it to allow an individual
> non-privileged process to change the distribution algorithm without impacting
> other processes.

Just to clarify : Installing a BPF filter on a SO_REUSEPORT socket is
not a privileged operation.
