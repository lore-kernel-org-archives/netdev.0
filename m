From: "Wong Edison" <hswong3i@gmail.com>
Subject: [PATCH 1/2] tcp-lp: bug fix for oops in 2.6.18-rc6
Date: Wed, 6 Sep 2006 04:41:34 +0800
Message-ID: <3feffd230609051341xfc6d0e9ib99a1b5cae8d009e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.197]:43208 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S899365AbWIEUuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 16:50:07 -0400
Received: by nz-out-0102.google.com with SMTP id n1so1149021nzf
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2006 13:41:34 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

   Folks: we do watch over you and your postings, if you get rejects
   do send UNABRIDGED messages to  <postmaster@vger.kernel.org>, however
   we do look into the FREEZER (as the reject message does refer to)
   several times a day to find possible mis-rejects.
	Yours,   <postmaster@vger.kernel.org>


Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN linux-2.6.18-rc6/MAINTAINERS linux/MAINTAINERS
--- linux-2.6.18-rc6/MAINTAINERS        2006-09-06 04:12:11.000000000 +0800
+++ linux/MAINTAINERS   2006-09-06 04:19:08.000000000 +0800
@@ -2818,6 +2818,14 @@ M:       hadi@cyberus.ca
 L:     netdev@vger.kernel.org
 S:     Maintained

+TCP LOW PRIORITY MODULE
+P:     Wong Hoi Sing, Edison
+M:     hswong3i@gmail.com
+P:     Hung Hing Lun, Mike
+M:     hlhung3i@gmail.com
+W:     http://tcp-lp-mod.sourceforge.net/
+S:     Maintained
+
 TI OMAP RANDOM NUMBER GENERATOR SUPPORT
 P:     Deepak Saxena
 M:     dsaxena@plexity.net
