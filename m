From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: [Question]The benefit of weight_p in __qdisc_run
Date: Wed, 17 Dec 2014 16:54:05 +0800
Message-ID: <CA+U0gVhk+4-T=XuCumnpRnRyQ=OqVfegGxF3ZZQy07++PDOW3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44194 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbaLQIy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 03:54:26 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so15794123pdi.2
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 00:54:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

weight_p is used as the burst xmit packet quota in the while loop of
the __qdisc_run function,
does anybody can elaborate the benefit of the weight_p introduced
here? what's the consequence without it?

Thanks!

-- 
Den
