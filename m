From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: How I can reset TCP sockets after long suspend/resume cyscle
Date: Sun, 1 Jun 2008 15:15:14 +0300
Message-ID: <200806011515.14103.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:54709 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbYFAMPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 08:15:19 -0400
Received: by nf-out-0910.google.com with SMTP id d3so263019nfc.21
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 05:15:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there a way to close all TCP sockets before/after suspend to ram?

It is so annoying that after a long suspend/resume cycle all applications
still wait for long closed connections.

Kmail/imap is the worst example here.

I tried to disable network interace, I tried even to remove its module
with no luck.

Best regards,
	Maxim Levitsky
