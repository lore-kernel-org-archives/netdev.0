From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] sctp: change sk state to CLOSED instead of
 CLOSING in sctp_sock_migrate
Date: Wed, 15 Jun 2016 22:20:03 +0300
Message-ID: <512f798b-cabd-36b2-bee5-53157fb48254@cogentembedded.com>
References: <9229f8aa0f4324831fc31b5334cde9a258404b62.1466010906.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	xiaolong.ye@intel.com, davem@davemloft.net, eric.dumazet@gmail.com
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34018 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbcFOTUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:20:07 -0400
Received: by mail-lf0-f45.google.com with SMTP id j7so26660647lfg.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 12:20:06 -0700 (PDT)
In-Reply-To: <9229f8aa0f4324831fc31b5334cde9a258404b62.1466010906.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/15/2016 08:15 PM, Xin Long wrote:

> Commit d46e416c11c8 ("sctp: sctp should change socket state when
> shutdown is received") may set sk_state CLOSING in sctp_sock_migrate,
> but inet_accept doesn't allow the sk_state other than ESTABLISHED/
> CLOSED for sctp. So we will change sk_state to CLOSED, instead of
> CLOSING, as actually sk is closed already there.
>
> Fixes: commit d46e416c11c8 ("sctp: sctp should change socket state when shutdown is received")

    "Commit" not needed here, this tag has well defined form.

> Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
[...]

MBR, Sergei
