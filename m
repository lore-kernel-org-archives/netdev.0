From: Shivaram Lingamneni <slingamn@cs.stanford.edu>
Subject: panic related to b44_poll
Date: Tue, 16 Dec 2014 21:20:36 -0800
Message-ID: <CAPcpQZhyqqYHnQC=SshmG0oetCDphmw6fW7tuqyTD8M1FimOiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: zambrano@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.cs.stanford.edu ([171.64.64.25]:48027 "EHLO
	smtp1.cs.Stanford.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaLQFuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 00:50:05 -0500
Received: from mail-pd0-f177.google.com ([209.85.192.177]:62165)
	by smtp1.cs.Stanford.EDU with esmtpsa (TLSv1:RC4-SHA:128)
	(Exim 4.80.1)
	(envelope-from <slingamn@cs.stanford.edu>)
	id 1Y172K-0006Gf-Ug
	for netdev@vger.kernel.org; Tue, 16 Dec 2014 21:20:37 -0800
Received: by mail-pd0-f177.google.com with SMTP id ft15so15164475pdb.8
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 21:20:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm experiencing a kernel panic, which I believe is caused by the b44
driver and triggered by the b44_poll call. Here are some pictures of
the panic on the 3.18 mainline kernel:

http://i.imgur.com/v4YPMei.jpg
http://i.imgur.com/8b6Sttw.jpg

Some additional information, including `lshw` output and a theory
about the conditions that cause the panic, is on the kernel bugzilla
issue here:

https://bugzilla.kernel.org/show_bug.cgi?id=89611

I have some additional photos with varying call traces on the RH
bugzilla issue here:

https://bugzilla.redhat.com/show_bug.cgi?id=1147321

however, the traces linked there are against the Fedora kernel, not
against the mainline kernel.

I'm not subscribed to the netdev list, so please cc me on responses.
Thanks very much for your time!
