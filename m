From: Brice Goglin <Brice.Goglin@ens-lyon.org>
Subject: Who's allowed to set a skb destructor?
Date: Wed, 04 Jul 2007 10:04:54 +0200
Message-ID: <468B54A6.5090902@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:49756 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754570AbXGDIE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 04:04:56 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by iona.labri.fr (Postfix) with ESMTP id D220A90097
	for <netdev@vger.kernel.org>; Wed,  4 Jul 2007 10:03:53 +0200 (CEST)
Received: from iona.labri.fr ([127.0.0.1])
	by localhost (iona.labri.fr [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id u5pqRE8AA2GS for <netdev@vger.kernel.org>;
	Wed,  4 Jul 2007 10:03:53 +0200 (CEST)
Received: from [147.210.128.231] (laptop-147-210-128-231.labri.fr [147.210.128.231])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by iona.labri.fr (Postfix) with ESMTP id BCB4B90094
	for <netdev@vger.kernel.org>; Wed,  4 Jul 2007 10:03:53 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am trying to understand whether I can setup a skb destructor in my
code (which is basically a protocol above dev_queue_xmit() and co). From
what I see in many parts in the current kernel code, the "protocol" (I
mean, the one who actually creates the skb) may setup a destructor.

However, I also see some places where some low-level drivers might be
using a destructor too , without apparently checking whether an upper
layer already uses one. For instance, write_ofld_wr() in cxgb3/sge.c. I
found some old threads about adding support for multiple destructors but
I don't see anything like this in the current kernel.

So, I'd like to have a clear statement about who's allowed to use a
destructor :)

Thanks,
Brice

