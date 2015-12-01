From: David Ahern <dsa@cumulusnetworks.com>
Subject: forwarding of ipv4 link local addresses
Date: Tue, 1 Dec 2015 13:35:58 -0800
Message-ID: <565E12BE.90006@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33586 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737AbbLAVgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:36:02 -0500
Received: by pabfh17 with SMTP id fh17so17885499pab.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 13:36:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 3927 states that packets from/to IPv4 link-local addresses 
(169.254/16) should not be forwarded, yet the Linux networking stack 
happily forwards them. Before sending in a patch I wanted to inquire if 
this behavior is intentional.

Thanks,
David
