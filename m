From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: hold the transport before using it in
 sctp_hash_cmp
Date: Thu, 8 Sep 2016 12:45:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00F7710@AcuExch.aculab.com>
References: <f71c2e03ae6e9b956f41c73fff5a282c86d79daf.1473328144.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:61913 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752200AbcIHMs1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 08:48:27 -0400
In-Reply-To: <f71c2e03ae6e9b956f41c73fff5a282c86d79daf.1473328144.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 08 September 2016 10:49
> Now sctp uses the transport without holding it in sctp_hash_cmp,
> it can cause a use-after-free panic. As after it get transport from
> hashtable, another CPU may free it, then the members it accesses
> may be unavailable memory.

How old is this bug?
Is it in any release kernels?

	David
