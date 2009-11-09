From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v5 0/5 RFC] TCPCT part1: cookie option exchange
Date: Mon, 09 Nov 2009 11:07:09 -0500
Message-ID: <4AF83E2D.1050401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:52202 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084AbZKIQHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 11:07:09 -0500
Received: by fxm21 with SMTP id 21so300728fxm.21
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 08:07:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm torn at the moment, as the net-next tree modules don't compile today.
Although 'make vmlinux' compiles this successfully, it is not tested.
Keep in mind that earlier variants were extensively tested.  But at least
this helps move the review comment process along....

Updated to patch cleanly with recent commits.

Changes from previous version:
  * swapped conditional tests, requested by Eric and Joe.
  * separate patch for constant cleanup, requested by Ilpo.
  * added hash generation of Responder Cookie with RCU locking.
  * shuffled a few bits to save another byte of tcp socket space.
