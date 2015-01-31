From: Cong Wang <cwang@twopensource.com>
Subject: Is sch_teql still useful?
Date: Fri, 30 Jan 2015 20:23:32 -0800
Message-ID: <CAHA+R7NDfn705P0OrgpMfx7nbsNcHh-cXrPVQezG9WtH1Ya3Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34034 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbbAaEXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 23:23:33 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so7901105igk.1
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 20:23:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Since we have bonding alb, is it still needed to have sch_teql since
they do the same thing, load balancing over multiple interfaces? Also
sch_teql mixes netdevice with qdisc, which somewhat breaks the
abstraction?

I don't dig the history so I could easily miss something here.

Thanks!
