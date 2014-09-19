From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual device
Date: Fri, 19 Sep 2014 15:57:06 -0700
Message-ID: <CAHA+R7MxiP9gZe2daJunXOKNa6sQd9JZ_4_ko6ipYGtshVP0bg@mail.gmail.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
	<1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
	<1411164317.26859.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M-HKbCmX3kEPLGrNjh+qF-OnL+V8C2biFBz24_7VOsxw@mail.gmail.com>
	<1411166670.26859.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:50740 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758064AbaISW5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:57:08 -0400
Received: by mail-la0-f44.google.com with SMTP id q1so3988483lam.31
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:57:07 -0700 (PDT)
In-Reply-To: <1411166670.26859.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Therefore, suggesting user to 'fix tx_queue_len' is totally wrong.

How about HTB? You said:

"Only when you want to have say HTB on the bonding, you might need to
change tx_queue_len"
