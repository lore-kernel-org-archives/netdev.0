From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: bcmgenet: cleanup for bcmgenet_xmit()
Date: Mon, 4 Apr 2016 17:58:57 -0700
Message-ID: <CAGVrzca_KuHbtxJVjDQWN38TKUVjOaM=XSmXr0_xUKxVWKnZhA@mail.gmail.com>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>, opendmb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37319 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756759AbcDEA7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 20:59:37 -0400
Received: by mail-ig0-f175.google.com with SMTP id g8so1030700igr.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 17:59:37 -0700 (PDT)
In-Reply-To: <1459815001-91703-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-04 17:09 GMT-07:00 Petri Gynther <pgynther@google.com>:
> 1. Readability: Move nr_frags assignment a few lines down in order
>    to bundle index -> ring -> txq calculations together.
> 2. Readability: Add parentheses around nr_frags + 1.
> 3. Minor fix: Stop the Tx queue and throw the error message only if
>    the Tx queue hasn't already been stopped.
>
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
