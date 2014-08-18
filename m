From: Cong Wang <cwang@twopensource.com>
Subject: Please backport commit e43ac79a4bc6ca9 to stable
Date: Mon, 18 Aug 2014 14:55:36 -0700
Message-ID: <CAHA+R7NrE5O+pncDFtXOV6MkitO+TuZiu5h0_oj0ybCtEAQpcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:45747 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbaHRVzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 17:55:38 -0400
Received: by mail-la0-f53.google.com with SMTP id gl10so5067465lab.40
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2014 14:55:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David


Please consider backporting the follow commit to stable:

commit e43ac79a4bc6ca90de4ba10983b4ca39cd215b4b
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue May 21 08:16:46 2013 +0000

    sch_tbf: segment too big GSO packets

Since GSO is turned on by default on modern NIC, this basically fixes
TBF with default configuration.

The following one is needed as well:

commit 4d0820cf6a55d72350cb2d24a4504f62fbde95d9
Author: Eric Dumazet <edumazet@google.com>
Date:   Sat Nov 23 12:59:20 2013 -0800

    sch_tbf: handle too small burst


Does this make any sense to you?

Thanks.
