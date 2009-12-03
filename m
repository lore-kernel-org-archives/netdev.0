From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v8 0/7] TCPCT part 1: cookie option exchange
Date: Wed, 02 Dec 2009 23:04:23 -0500
Message-ID: <4B1738C7.7090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:56163 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbZLCEEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 23:04:21 -0500
Received: by ywh12 with SMTP id 12so1054899ywh.21
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2009 20:04:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initiator                            Responder
=========                            =========
<SYN>                          ->
Cookie
                                 <-   <SYN,ACK(SYN)>
                                      Cookie
                                      optional data


V8:
Updated to patch cleanly with recent large commits.

Compiled and lightly tested.  Awaiting performance testing results.

Cosmetic changes, based on review by David Miller.

Merged some part 2 code to relieve ennui.


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
