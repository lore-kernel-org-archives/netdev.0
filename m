From: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Subject: a question on packet_sock struct
Date: Wed, 12 Aug 2009 15:43:59 +0900
Message-ID: <2014bcab0908112343x68d758e7x132f86b951093e12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f175.google.com ([209.85.210.175]:40068 "EHLO
	mail-yx0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbZHLGn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 02:43:59 -0400
Received: by yxe5 with SMTP id 5so5416681yxe.33
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 23:43:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. I have a question on packet_sock struct
defined in net/packet/af_packet.c of Linux 2.6.30.4.

Is it necessary to hold a packet_sock's bind_lock
before accessing its ifindex field?

According to the definition of packet_sock struct,
it seems that an access to ifindex field should be
synchronized by the bind_lock.

However, according to the its usage in the code,
ifindex accesses are not consistently protected
by the bind_lock.

Thank you

Sincerely
Shin Hong
