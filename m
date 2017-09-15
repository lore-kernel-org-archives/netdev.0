From: Roland Hopferwieser <rhopfer@ica.jku.at>
Subject: [PATCH iproute2] Add information about COLORFGBG to ip.8 man page
Date: Fri, 15 Sep 2017 22:04:16 +0200
Message-ID: <873bbae3-db89-b572-748b-cfa62922f883@ica.jku.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iris.ica.jku.at ([140.78.104.135]:49423 "HELO iris.ica.jku.at"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
        id S1751741AbdIOUOB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 16:14:01 -0400
Received: from [192.168.0.4] (cm56-199-141.liwest.at [86.56.199.141])
        by iris.ica.jku.at (Postfix) with ESMTPSA id 2EA13100174C
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 22:04:17 +0200 (CEST)
Content-Language: de-CH
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


diff --git a/man/man8/ip.8 b/man/man8/ip.8
index ae018fdf..2a27a56e 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -187,7 +187,8 @@ executes specified command over all objects, it 
depends if command supports this

  .TP
  .BR "\-c" , " -color"
-Use color output.
+Use color output. The color palette is affected by the COLORFGBG 
environment variable, which typically has the form "fg;bg".
+If "bg" is set to 0-6 or 8, the dark color palette is used.

  .TP
  .BR "\-t" , " \-timestamp"
