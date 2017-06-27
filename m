From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] man: Collect names of man pages automatically
Date: Tue, 27 Jun 2017 16:06:30 -0700
Message-ID: <20170627160630.38f623a4@xeon-e3>
References: <20170627190025.450-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34213 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753935AbdF0XGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:06:32 -0400
Received: by mail-pg0-f48.google.com with SMTP id t186so22570731pgb.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:06:32 -0700 (PDT)
In-Reply-To: <20170627190025.450-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jun 2017 21:00:25 +0200
Phil Sutter <phil@nwl.cc> wrote:

> As it turned out, forgetting to add a man page to the respective
> Makefile when introducing it is a common mistake. Overcome this once and
> for all by using $(wildcard) function in Makefiles.
> 
> Fixes: 7124942942e53 ("genl: add manpage")
> Fixes: 958cd210942c8 ("ifcfg: add manpage")
> Fixes: e1b7f883e50de ("man: add documentation for IPv6 SR commands")
> Fixes: 1949f82cdf62c ("Introduce ip vrf command")
> Fixes: 535194a172d23 ("tipc: add peer remove functionality")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Thanks for fixing this common mistake.
Applied.
