From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 4/7] net-tcp: Fast Open client - receiving SYN-ACK
Date: Mon, 16 Jul 2012 15:57:54 -0700
Message-ID: <CAGK4HS9iEVy6NEx_dJgdEW8P2K9_G0vhziE+7O7iW+6WFc3VEw@mail.gmail.com>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
	<1342473410-6265-5-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47096 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab2GPW5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 18:57:55 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so5889474yhm.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 15:57:54 -0700 (PDT)
In-Reply-To: <1342473410-6265-5-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16 July 2012 14:16, Yuchung Cheng <ycheng@google.com> wrote:
> On receiving the SYN-ACK after SYN-data, the client needs to
> a) update the cached MSS and cookie (if included in SYN-ACK)
> b) retransmit the data yet acknowledged by the SYN-ACK in the final ACK of
>    the handshake.

I think you mean "data not yet acknowledged " in point (b).

Vijay
