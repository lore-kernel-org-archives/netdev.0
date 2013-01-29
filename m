From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] tcp: Increment LISTENOVERFLOW and LISTENDROPS in tcp_v4_conn_request()
Date: Mon, 28 Jan 2013 22:16:00 -0800
Message-ID: <CAGK4HS_D3DLp_-PWmRQcgz-yGPnXF0bzg0xDtxJTsnwAG=Bbrw@mail.gmail.com>
References: <1359431557-4587-1-git-send-email-niveditasinghvi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:51715 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530Ab3A2GQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 01:16:01 -0500
Received: by mail-qa0-f45.google.com with SMTP id g10so1426354qah.4
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2013 22:16:00 -0800 (PST)
In-Reply-To: <1359431557-4587-1-git-send-email-niveditasinghvi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 January 2013 19:52, Nivedita Singhvi <niveditasinghvi@gmail.com> wrote:
> From: Nivedita Singhvi <niv@us.ibm.com>
>
> We drop a connection request if the accept backlog is full and there are
> sufficient packets in the syn queue to warrant starting drops. Increment the
> appropriate counters so this isn't silent, for accurate stats and help in
> debugging.
>
> This patch assumes LINUX_MIB_LISTENDROPS is a superset of/includes the
> counter LINUX_MIB_LISTENOVERFLOWS.
>
> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
> ---

Thanks !

Acked-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Please do add version number of patch in subject line and changes
since last version in future to avoid confusion.
Regards,
Vijay
