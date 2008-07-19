From: "Adam Langley" <agl@imperialviolet.org>
Subject: [RFC 0/2] TCP: Add TCP-AO support
Date: Fri, 18 Jul 2008 17:22:10 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069030@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:23763 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbYGSAVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:21:03 -0400
Received: by rv-out-0506.google.com with SMTP id k40so506472rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 17:21:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an experimental pair of patches which adds support for TCP-AO[1]. AO
(Auth option) is the replacement for TCP MD5 signatures, adding different MAC
functions, shorter functions, key rotation etc. See the comments at the top of
the 2/2 patch for details.

This patch still supports the TCP MD5 setsockopt as always, it's just a wrapper
around the TCP-AO code now.

The 1/2 patch is just a rename patch (s/md5sig/auth/ more of less). It gets its
own patch because, otherwise, you wouldn't be able to see the actual changes
for the noise.

This is only intended for comments on the userland interface and for anyone who
wishes to play with it. If you're in the latter set, I have a netcat-like tool
which can use the new interfaces.

[1] http://www.ietf.org/internet-drafts/draft-ietf-tcpm-tcp-auth-opt-01.txt
