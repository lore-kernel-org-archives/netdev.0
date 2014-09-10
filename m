From: Robert Engels <rengels@optionscity.com>
Subject: rtt vs. rcv_rtt
Date: Wed, 10 Sep 2014 12:56:04 -0500
Message-ID: <CA+q+rD3Z9JEW=4hyAutTxa9yk3mtR-yakUUU4o3sKrfMQkfh6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:54725 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaIJR4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 13:56:06 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so873144wib.8
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 10:56:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using 'ss', both rtt, and rcv_rtt are reported.

My understanding is that rcv_rtt is an estimate of the receivers rtt
?? Is this true?

My assumption is that differences in rtt vs. rcv_rtt would be due to
asymmetric networking connections ???

Here is a sample 'ss' output:

cubic wscale:2,9 rto:437 rtt:101.625/84 ato:40 cwnd:10 ssthresh:15
send 991.9Kbps rcv_rtt:18291 rcv_space:151142

Can someone explain why the rcv_rtt would be so much higher than the rtt?

Is it that the client is not reading the data fast enough? Other reasons?

Thanks so much for your help.

Robert Engels
