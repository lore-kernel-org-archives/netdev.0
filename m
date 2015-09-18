From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] geneve: use network byte order for destination port
 config parameter
Date: Fri, 18 Sep 2015 13:14:02 -0700
Message-ID: <CAEP_g=-mSN8zQPv+WjLVZGoQe=_kbU6GkyZ3+nHVfzXMtpXmMQ@mail.gmail.com>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com> <1442606350-11170-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:32820 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbbIRUOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 16:14:24 -0400
Received: by lamp12 with SMTP id p12so36155946lam.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 13:14:22 -0700 (PDT)
In-Reply-To: <1442606350-11170-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 12:59 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> This is primarily for consistancy with vxlan and other tunnels which
> use network byte order for similar parameters.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> It is OK to change this, since this parameter was introduced to
> net-next in the pre-4.3 cycle.  Using network byte order for this
> parameter is consistent with what the other tunnels are doing.

Reviewed-by: Jesse Gross <jesse@nicira.com>

Thanks!
