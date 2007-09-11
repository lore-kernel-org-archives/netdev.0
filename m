From: "Primiano Tucci" <p.tucci@gmail.com>
Subject: calling dev_queue_xmit from softirq
Date: Tue, 11 Sep 2007 12:14:03 +0200
Message-ID: <c5b2c05b0709110314x6cc00df8w1f37a26eb9998efa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:32904 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbXIKKOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 06:14:03 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1271356rvb
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 03:14:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all, just a simple question here:
can dev_queue_xmit be called from atomic context (a softirq for instance)
or do i have to put the dev_queue_xmit call in a separate tasklet and call
it from tasklet?
Kernel 2.6.22

Thanks in advance
Primiano Tucci
