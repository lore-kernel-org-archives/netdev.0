From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] tc: m_xt: Prevent a segfault in libipt
Date: Tue, 30 May 2017 17:38:47 -0700
Message-ID: <20170530173847.0580cf36@xeon-e3>
References: <20170523134057.23775-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <psutter@redhat.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36135 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdEaAit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:38:49 -0400
Received: by mail-pf0-f171.google.com with SMTP id m17so1829535pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:38:49 -0700 (PDT)
In-Reply-To: <20170523134057.23775-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 May 2017 15:40:57 +0200
Phil Sutter <phil@nwl.cc> wrote:

> From: Phil Sutter <psutter@redhat.com>
> 
> This happens with NAT targets, such as SNAT, DNAT and MASQUERADE. These
> are still not usable with this patch, but at least tc doesn't crash
> anymore when one tries to use them.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks
