From: Thorben Hasenpusch <thorben.hasenpusch@gmail.com>
Subject: Userspace header linux/netlink.h uses GCC-specific 'typeof'
Date: Tue, 10 Sep 2013 14:51:16 +0200
Message-ID: <1378817476.2011.2.camel@jumpzero>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:47773 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab3IJMvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 08:51:21 -0400
Received: by mail-ea0-f180.google.com with SMTP id h10so3801545eaj.39
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 05:51:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compilation of a user space program which includes linux/netlink.h and
uses NL_MMAP_MSG_ALIGN fails if GCC is ordered not to use GNU
extensions.
__KERNEL_ALIGN is defined to use typeof which is a GCC-extension and not
supported by standard C/C++.
Can that be changed so standard conforming C/C++ compiles successfully?

Regards.
