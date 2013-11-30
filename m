From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net v2 2/7] e1000: prevent oops when adapter is being closed
 and reset simultaneously
Date: Sat, 30 Nov 2013 20:37:48 +0400
Message-ID: <529A145C.4030503@cogentembedded.com>
References: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com> <1385803221-3752-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yzhu1 <yanjun.zhu@windriver.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:39408 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712Ab3K3Qhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 11:37:50 -0500
Received: by mail-lb0-f181.google.com with SMTP id q8so7733070lbi.12
        for <netdev@vger.kernel.org>; Sat, 30 Nov 2013 08:37:47 -0800 (PST)
In-Reply-To: <1385803221-3752-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 30-11-2013 13:20, Jeff Kirsher wrote:

> From: yzhu1 <yanjun.zhu@windriver.com>

> This change is based on a similar change made to e1000e support in
> commit bb9e44d0d0f4 ("e1000e: prevent oops when adapter is being closed
> and reset simultaneously").  The same issue has also been observed
> on the older e1000 cards.

> Here, we have increased the RESET_COUNT value to 50 because there are too
> many accesses to e1000 nic on stress tests to e1000 nic, it is not enough
> to set RESET_COUT 25. Experimentation has shown that it is enough to set
> RESET_COUNT 50.

> Signed-off-by: yzhu1 <yanjun.zhu@windriver.com>

    Jeff, why are you accepting patches without real name in the sign-off line?

> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

WBR, Sergei
