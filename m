From: "durgam@it.iitb.ac.in phani" <durgam.iit@gmail.com>
Subject: proxy arp bug
Date: Wed, 23 Apr 2008 19:21:56 +0530
Message-ID: <f46324890804230651r6bb15a98ma746d60d4c499275@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:20607 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbYDWNv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 09:51:58 -0400
Received: by py-out-1112.google.com with SMTP id u52so4214004pyb.10
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 06:51:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1027 says  "The default route must not be used when checking for a
route to the target host of an ARP request. If the default route were
used, the check would always
   succeed."

    But when i tested ,  linux OS is considering this default route
also. Any configuration parameter needs to be set to make it work
properly or is it the desired behaviour?

Thanks
 Pani
