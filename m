From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v7 0/7 RFC] TCPCT part 1: cookie option exchange
Date: Fri, 20 Nov 2009 09:04:47 -0500
Message-ID: <4B06A1FF.8000202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:37436 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbZKTOEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 09:04:45 -0500
Received: by yxe17 with SMTP id 17so2921754yxe.33
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 06:04:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initiator                            Responder
=========                            =========
<SYN>                          ->
Cookie
                                 <-   <SYN,ACK(SYN)>
                                      Cookie
                                      optional data


V7:
Updated to patch cleanly with recent large commits.

Compiled and lightly tested.  Awaiting performance testing results.

Revised RCU spinlocks, based on review by Eric and Joe.

Trivial savings of 2 if tests, based on review by Joe.

Cosmetic changes to comment blocks, based on review by Eric.

Processing optional SYNACK data removed until later.


V6:
The new TCP_MSS_* symbols are now in an entirely separate patch.  Applied.

Updated and reorganized to split the code base into several pieces, as
requested by Eric.  No significant changes.

...
