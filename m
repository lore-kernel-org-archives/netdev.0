From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisect] 3.18 oops in tcp_v4_send_reset()
Date: Tue, 09 Dec 2014 09:23:24 -0800
Message-ID: <1418145804.27198.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141209160023.GA31520@fluid.dannf>
	 <1418141783.14835.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1418141914.14835.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1418142520.14835.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALdTtnuazPdMNsOHzzersmyHvLjwxSq1BZoA5ZAdU-0QZtwUsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dann Frazier <dann.frazier@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38598 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaLIRX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 12:23:28 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so4920287igi.12
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 09:23:27 -0800 (PST)
In-Reply-To: <CALdTtnuazPdMNsOHzzersmyHvLjwxSq1BZoA5ZAdU-0QZtwUsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 10:10 -0700, Dann Frazier wrote:

> This patch does appear to resolve the issue, thanks Eric!

Thanks Dann

I need to cook a proper patch including ipv6 changes.
