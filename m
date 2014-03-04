From: Andy Lutomirski <luto@amacapital.net>
Subject: What is SOF_TIMESTAMPING_RX_HARDWARE?
Date: Mon, 3 Mar 2014 18:20:33 -0800
Message-ID: <CALCETrULL_QJqSLSCcySdUdj5sGgh8A7gyEn=vpgCC4LDjPHFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:38821 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241AbaCDCUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 21:20:54 -0500
Received: by mail-ve0-f173.google.com with SMTP id oy12so2592244veb.18
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 18:20:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAICT is sets SOCK_TIMESTAMPING_RX_HARDWARE, which appears to do
exactly nothing.  If I'm right, should I submit a patch documenting
that fact and removing the getsockopt/setsockopt implementations?

On the other hand, SOCK_TIMESTAMPING_SYS_HARDWARE and
SOCK_TIMESTAMPING_RAW_HARDWARE actually work.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
