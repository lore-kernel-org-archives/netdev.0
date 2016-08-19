From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 2/2] sctp: not copying duplicate addrs to the assoc's
 bind address list
Date: Fri, 19 Aug 2016 23:16:41 +0800
Message-ID: <CADvbK_fo8o1nOvo58PdrkkT6ffGv7r5NhDUazBw67mwwfcwitA@mail.gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com> <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819133001.GA3578@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33661 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754040AbcHSPQn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 11:16:43 -0400
In-Reply-To: <20160819133001.GA3578@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Under what valid use case will multiple interfaces have the same network
> address?
>
Hi, Neil.
I'm not sure the specific valid use case.

The point is, do we trust the sctp global addr list has no duplicate
address ? In one of users' computer, he found hundreds of duplicate
addresses in INIT_ACK packets.
(https://bugzilla.redhat.com/show_bug.cgi?id=1308362)

If we think NETDEV_UP/DOWN event in addrs chain always come
in pairs, I can not explain how come this issue happened.

But from sctp end, we can avoid it with this patch. after all
binding any duplicate addresses is illegal, just like what
sctp_bind does.

what do you think ?
