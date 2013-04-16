From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Tue, 16 Apr 2013 15:56:29 -0700
Message-ID: <1366152989.3205.12.camel@edumazet-glaptop>
References: <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven> <1363223884.29475.0.camel@edumazet-glaptop>
	 <20130314144550.GB2512@raven> <1363273531.29475.21.camel@edumazet-glaptop>
	 <1363274946.29475.24.camel@edumazet-glaptop>
	 <1365697961.3887.176.camel@edumazet-glaptop>
	 <1365702804.3887.180.camel@edumazet-glaptop> <20130416202022.GB2545@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42713 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965533Ab3DPW4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 18:56:31 -0400
Received: by mail-pd0-f180.google.com with SMTP id q11so534289pdj.11
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 15:56:31 -0700 (PDT)
In-Reply-To: <20130416202022.GB2545@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 21:20 +0100, Tom Parkin wrote:

> Thanks Eric, I've tested this patch here and it looks good.  Usually I
> see an oops within 30 mins or so with my workload, but with this
> change I've run for over two hours with no issues.
> 

Thanks Tom, I submitted the official patch.
