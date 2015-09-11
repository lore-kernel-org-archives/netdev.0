From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: [fw filter]: Broken! fw mark based tc class selection not working
Date: Fri, 11 Sep 2015 23:34:19 +0700
Message-ID: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33079 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbbIKQeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 12:34:19 -0400
Received: by oixx17 with SMTP id x17so45866549oix.0
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 09:34:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I came to know that,
Without any options fw classifier maps fwmark to classid.

tc filter add dev <iface> parent <qhandle> protocol ip prio 1 fw

i.e. if my packet has mark(0x10001) and class id is not set,
then above tc filter, will set class id = 0x10001 i.e. 1:1

But when I am trying it out, its not working!
I am having class 1:1 defined but its not at all hit.
