From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 4/4] sctp: fix some type cast warnings introduced
 since very beginning
Date: Mon, 30 Oct 2017 11:12:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00A8AA8@AcuExch.aculab.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
 <40b05aa84d107b434bae3794692ac2da61da65ca.1509190967.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:62396 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdJ3LMP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 07:12:15 -0400
In-Reply-To: <40b05aa84d107b434bae3794692ac2da61da65ca.1509190967.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 28 October 2017 12:44
> These warnings were found by running 'make C=2 M=net/sctp/'.
> They are there since very beginning.
...
> -		param.crr_id = i;
> +		param.crr_id = htonl(i);
...

Isn't this a bug fix, not just removing a warning??

	David
