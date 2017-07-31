From: Massimo Sala <massimo.sala.71@gmail.com>
Subject: new sysctl tunable knob : tcp_retries2_time
Date: Mon, 31 Jul 2017 18:17:48 +0200
Message-ID: <CAKv20-UNHrR-WwWYsPH4AHdbu+Qd2o7X5TXDDnJMA5-w7G9E9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:37187 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbdGaQRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 12:17:51 -0400
Received: by mail-lf0-f47.google.com with SMTP id m86so108796487lfi.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 09:17:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wish to suggest to developers to add this new knob :

tcp_retries2_time - INTEGER
	This value influences the timeout (seconds) of an alive TCP connection,
	when RTO retransmissions remain unacknowledged.
        RFC 1122 recommends at least 100 seconds for the timeout,
	which corresponds to a value of at least 8.


Rationale :
* I see a lot of misuse of tcp_retries2, because even if you check the
RTO, it will change with different connections, routing, etc... and so
tcp_retries2 timeout will change.

* An absolute value will be friendly and better ton read and document.
See other parameters with two knobs ( example : dirty_ratio,
dirty_ratio_bytes ).

Best regards, Sala
