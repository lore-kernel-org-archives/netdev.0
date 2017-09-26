From: Roland Hopferwieser <rhopfer@ica.jku.at>
Subject: Re: [PATCH iproute2] Add information about COLORFGBG to ip.8 man page
Date: Wed, 27 Sep 2017 01:46:55 +0200
Message-ID: <91dfb135-c440-30d7-e14a-16d91b99dc0a@ica.jku.at>
References: <873bbae3-db89-b572-748b-cfa62922f883@ica.jku.at>
 <20170920175633.55ee67c9@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------57D69F0492CCA497231FFEC1"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iris.ica.jku.at ([140.78.104.135]:59154 "HELO iris.ica.jku.at"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
        id S968440AbdIZXq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 19:46:57 -0400
In-Reply-To: <20170920175633.55ee67c9@xeon-e3>
Content-Language: de-CH
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------57D69F0492CCA497231FFEC1
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

> Your patch was damaged by the mailer you used.
> Please fix and resubmit.

Sorry, now as attachment.

--------------57D69F0492CCA497231FFEC1
Content-Type: text/x-patch;
 name="iproute2-Add-information-about-COLORFGBG-to-ip.8-man-page.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="iproute2-Add-information-about-COLORFGBG-to-ip.8-man-page.pa";
 filename*1="tch"

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index ae018fdf..2a27a56e 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -187,7 +187,8 @@ executes specified command over all objects, it depends if command supports this
 
 .TP
 .BR "\-c" , " -color"
-Use color output.
+Use color output. The color palette is affected by the COLORFGBG environment variable, which typically has the form "fg;bg".
+If "bg" is set to 0-6 or 8, the dark color palette is used.
 
 .TP
 .BR "\-t" , " \-timestamp"

--------------57D69F0492CCA497231FFEC1--
