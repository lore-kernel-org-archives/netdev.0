From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCHv3 net-next] net: use jiffies_to_msecs to replace EXPIRES_IN_MS in inet/sctp_diag
Date: Tue, 19 Apr 2016 11:13:07 +0200
Message-ID: <87mvoqotb0.fsf@beetle.home>
References: <87a0e83132ce64a3fe2266a5323fa6577a2e5c96.1461049801.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37264 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbcDSJNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 05:13:10 -0400
Received: by mail-wm0-f48.google.com with SMTP id n3so18386731wmn.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 02:13:09 -0700 (PDT)
In-reply-to: <87a0e83132ce64a3fe2266a5323fa6577a2e5c96.1461049801.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 09:10 AM CEST, Xin Long <lucien.xin@gmail.com> wrote:
> EXPIRES_IN_MS macro comes from net/ipv4/inet_diag.c and dates
> back to before jiffies_to_msecs() has been introduced.
>
> Now we can remove it and use jiffies_to_msecs().
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---

Acked-by: Jakub Sitnicki <jkbs@redhat.com>
