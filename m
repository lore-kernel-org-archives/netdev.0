From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/7] sch_netem: clear old rate when old qdisc's
 replaced
Date: Fri, 14 Feb 2014 04:43:04 -0800
Message-ID: <1392381784.24974.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
	 <1392366970-11592-7-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:52513 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbaBNMnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 07:43:06 -0500
Received: by mail-pd0-f178.google.com with SMTP id fp1so3240961pdb.9
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 04:43:05 -0800 (PST)
In-Reply-To: <1392366970-11592-7-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-14 at 16:36 +0800, Yang Yingliang wrote:
> If we set a netem qdisc with rate option, while we
> use "#tc qdisc replace ..." that without rate option
> to replace the old qdisc, the old rate is still there.
> We need clear old rate after qdisc's replaced.

Wait... Have you tested :

tc qdisc change ...

This is far more needed than 'replace' : 

You (meaning user scripts) can implement replace by delete + create, but
'tc qdisc change' needs current code.
