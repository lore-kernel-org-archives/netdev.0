From: Naeem Khademi <naeem.khademi@gmail.com>
Subject: [PATCH] fixing adaptive-red average queuing in man/man8/tc-red.8
Date: Wed, 14 Aug 2013 17:51:36 +0200
Message-ID: <CAEjQQ5WLe4ZOML9D0rnuSNcjSazBFW4JhKp+iMqZVxO_Ckhj-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:47754 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759697Ab3HNPvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 11:51:37 -0400
Received: by mail-vb0-f47.google.com with SMTP id h10so7645902vbh.20
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 08:51:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a mistake in documenting adaptive-RED's formula of
average queuing in man. The ARED's target average queuing is
(max+min)/2.

Regards,

diff --git a/man/man8/tc-red.8 b/man/man8/tc-red.8
index f410d15..466000d 100644
--- a/man/man8/tc-red.8
+++ b/man/man8/tc-red.8
@@ -127,7 +127,7 @@ adaptive
 (Added in linux-3.3) Sets RED in adaptive mode as described in
http://icir.org/floyd/papers/adaptiveRed.pdf
 .nf
 Goal of Adaptive RED is to make 'probability' dynamic value between
1% and 50% to reach the target average queue :
-.B (max - min) / 2
+.B (max + min) / 2
 .fi

 .SH EXAMPLE
