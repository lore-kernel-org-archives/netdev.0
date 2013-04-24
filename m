From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet overflow
Date: Tue, 23 Apr 2013 20:00:45 -0400
Message-ID: <CA+FuTSfKoVDQ2FqS_h-X6pkjmJuegXMZ2p9tvmoXNDFQ-0dLNA@mail.gmail.com>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
 <1366749094-5982-1-git-send-email-willemb@google.com> <20130423.184140.2020239496583590253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:51354 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036Ab3DXABQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 20:01:16 -0400
Received: by mail-ie0-f170.google.com with SMTP id at1so1424945iec.1
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 17:01:15 -0700 (PDT)
In-Reply-To: <20130423.184140.2020239496583590253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 6:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Tue, 23 Apr 2013 16:31:34 -0400
>
>> - disable the kconfig option by default, as it is workload specific.
>
> If this logic only kicks in during overload, I see no reason why we
> shouldn't have this protection enabled unconditionally, all the time.
>
> Does it hurt performance under normal workloads?
>
> If the new logic is controlled by overload thresholds then it should
> have no impact whatsoever in non-overload scenerios.

It only adds one branch in that case. I was (probably too) conservative.

Do you want me to resubmit the entire patch with the Kconfig
dependency on RPS that Eric proposed?
