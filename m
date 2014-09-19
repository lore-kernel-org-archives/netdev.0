From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 15:44:30 -0700
Message-ID: <1411166670.26859.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	 <CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
	 <1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
	 <1411164317.26859.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M-HKbCmX3kEPLGrNjh+qF-OnL+V8C2biFBz24_7VOsxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:52402 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbaISWod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:44:33 -0400
Received: by mail-pa0-f51.google.com with SMTP id fa1so947033pad.24
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:44:32 -0700 (PDT)
In-Reply-To: <CAHA+R7M-HKbCmX3kEPLGrNjh+qF-OnL+V8C2biFBz24_7VOsxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 15:14 -0700, Cong Wang wrote:

> Conflicts with what you claimed by "I disagree." :)

Whats wrong with using macvlan on top of bonding device where
tx_queue_len needs to be 0, because we do not want a qdisc on it ?

Therefore, suggesting user to 'fix tx_queue_len' is totally wrong.

Fix macvlan driver, and do not try to 'fix user scripts'

Thats very simple.
