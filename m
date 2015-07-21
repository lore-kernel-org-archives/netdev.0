From: Guru Prasad <gurupras@buffalo.edu>
Subject: Identifying underlying interface from struct sock
Date: Tue, 21 Jul 2015 13:09:10 -0400
Message-ID: <CAMefCkC8CSVLSgy9J4TxiXCAQ-ueLTgk1pT2QJ6hACyNZf_kTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33209 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753AbbGURJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:09:13 -0400
Received: by ietj16 with SMTP id j16so147715505iet.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 10:09:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

First, I apologize for posting on the netdev forum. Majordomo did not
list any other network related mailing list.

Is there a way to identify the underlying network interface from an
instance of struct sock? I realize that the socket is abstract and
shouldn't/doesn't necessarily depend on the underlying interface, but
say, with TCP, where the connection is endpoint oriented, shouldn't
this mean that the socket maintains a reference to the interface to
which it is associated?

I tried
dev = dev_get_by_index(sock_net(sk), skb->skb_iif);
and
dev = skb->dev;
but in both cases, dev was NULL.

I'm trying to reference the underlying interface to determine whether
the conditions present in that interface are acceptable for
transmission.
