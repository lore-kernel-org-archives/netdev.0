From: Rayagond K <rayagond@vayavyalabs.com>
Subject: flow control handling in network driver
Date: Wed, 26 Sep 2012 14:48:35 +0530
Message-ID: <CAJ3bTp4J4aLzPgDND6E6SMXZe05xnM7K9kHVCH7kD-=vYZNtHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62776 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab2IZJSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 05:18:36 -0400
Received: by bkcjk13 with SMTP id jk13so169202bkc.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 02:18:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

What is the use of two macros SUPPORTED_Pause and SUPPORTED_Asym_Pause
which are defined in ethtool.h file.

I have seen amny driver in lxr using above macros, for example tg3
driver - uses these macros to advertise the phy capabilities.

Flow control is MAC feature not PHY, hence when can one use above
macros and what is the use of it. Should we use these macros to
implement flow control in Ethernet driver ?

Thanks in advance.

--
wwr
Rayagond
