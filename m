From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [PATCH 1/2] tcp: setup random timestamp offset when write_seq
 already set
Date: Mon, 20 Feb 2017 19:29:26 +0300
Message-ID: <65bedad0-0e42-3cb1-091c-8cef2b323f75@oracle.com>
References: <1487379372-28199-1-git-send-email-alexey.kodanev@oracle.com>
 <20170220.101807.883027207624802826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39406 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdBTQ3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:29:51 -0500
In-Reply-To: <20170220.101807.883027207624802826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.02.2017 18:18, David Miller wrote:
> This would be so much easier to understand if it were coded as:
> 	if (!tp->repair) {
> 		seq = secure_tcp_sequence_number(...);
> 		if (!tp->write_seq)
> 			tp->write_seq = seq;
> 	}

Hi David,

Thought about not adding extra variable here...
Agree,it looks much better and easier to follow.

Should I send a patch with this version modified as you
suggested or we can inherit ts offsetfrom tcptw->tw_ts_offset
in tcp_twsk_unique()?

Thanks,
Alexey
