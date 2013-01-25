From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in tcp_v4_conn_request()
Date: Thu, 24 Jan 2013 23:29:16 -0800
Message-ID: <CAGK4HS8ABKqa8J1Sd1Q52P4p3=KcSokQQX0e90FWV6aZsVdP3A@mail.gmail.com>
References: <1359097408-9786-1-git-send-email-niv@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Leandro Lucarella <leandro.lucarella@sociomantic.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:51995 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab3AYH3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 02:29:17 -0500
Received: by mail-qc0-f177.google.com with SMTP id u28so31526qcs.8
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 23:29:17 -0800 (PST)
In-Reply-To: <1359097408-9786-1-git-send-email-niv@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 January 2013 23:03, Nivedita Singhvi <niveditasinghvi@gmail.com> wrote:
> We drop a connection request if the accept backlog, syn queue are full when processing reaches tcp_v4_conn_request(). Increment the appropriate counter so this isn't silent, for accurate stats and help in debugging.
>

Commit message seems misleading. syn queue is not really full at this
point. It just has more than enough entries.

Thanks,
Vijay
