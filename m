From: "Adam Langley" <agl@imperialviolet.org>
Subject: seq/ack numbers in tcp_info?
Date: Tue, 8 Jul 2008 19:30:09 -0700
Message-ID: <396556a20807081930i14e1a689r3461539f2e23f286@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:56100 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbYGICaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 22:30:09 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3389505rvb.1
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2008 19:30:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would there be any objections to exporting the SEQ/ACK numbers for a
TCP connection to userspace via a getsockopt? TCP_INFO would be the
obvious place to put it and, as long as they're added to the end, the
current truncating logic is sufficient to maintain ABI compatibility.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
