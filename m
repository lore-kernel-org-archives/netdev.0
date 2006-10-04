From: "Ronghua Zhang" <ronghuazhang@gmail.com>
Subject: are all protocol headers in the linear part of a sk_buff?
Date: Wed, 4 Oct 2006 01:19:56 -0700
Message-ID: <ba020e9f0610040119k70aabccfic109dbf2c103846b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:1341 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030666AbWJDIT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 04:19:59 -0400
Received: by py-out-1112.google.com with SMTP id n25so162178pyg
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2006 01:19:57 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a skb reaches a device driver for tx, can the driver assumes that
all protocol headers (up to the tcp layer and including tcp options)
are in the linear part of the skb, thus it can access them via
skb->h.th? Or the answer depends on the linux kernel version? Thanks

Ronghua
