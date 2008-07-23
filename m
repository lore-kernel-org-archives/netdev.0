From: Alex Davis <alex14641@yahoo.com>
Subject: Possible coding error in ./drivers/net/wan/dlci.c
Date: Wed, 23 Jul 2008 16:55:06 -0700 (PDT)
Message-ID: <127008.37767.qm@web50202.mail.re2.yahoo.com>
References: <20080723191443.GT10471@solarflare.com>
Reply-To: alex14641@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50202.mail.re2.yahoo.com ([206.190.38.43]:38673 "HELO
	web50202.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754686AbYGWXzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 19:55:08 -0400
In-Reply-To: <20080723191443.GT10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the 2.6.25.10 version of this file, function dlci_del, the function __dev_get_by_name is called with neither the RTNL semaphore or dev_base_lock being held. According to the documentation for __dev_get_by_name, one of the aforementioned locks must be held. Am I missing something?


I code, therefore I am


      
