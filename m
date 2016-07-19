From: Chas Williams <3chas3@gmail.com>
Subject: 4.4 Backport request 4d06dd537f95 cdc_ncm: do not call
 usbnet_link_change from cdc_ncm_bind
Date: Tue, 19 Jul 2016 14:41:27 -0400
Message-ID: <1468953687.5676.5.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33543 "EHLO
	mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbcGSSla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 14:41:30 -0400
Received: by mail-qt0-f178.google.com with SMTP id w38so14231022qtb.0
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:41:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can

4d06dd537f95 cdc_ncm: do not call usbnet_link_change from cdc_ncm_bind

be added to 4.4 stable? =C2=A0This fixes=C2=A0CVE-2016-3951 [The second=
 half
necessary for a complete fix, 666984c8625 ("usbnet: cleanup after bind(=
)
in probe()"), is already present in 4.4.]

Thanks!
