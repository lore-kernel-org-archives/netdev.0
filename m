From: Tom Gundersen <teg@jklm.no>
Subject: [BUG?] bridge_id not getting set for bridges created with
Date: Mon, 21 Apr 2014 21:33:13 +0200
Message-ID: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "C. R. Oldham" <cr@saltstack.com>
To: netdev <netdev@vger.kernel.org>, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:57237 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaDUTiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 15:38:46 -0400
Received: by mail-yk0-f178.google.com with SMTP id 79so3741676ykr.37
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 12:38:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

If IFLA_ADDRESS is set when creating a bridge over netlink, e.g.

# ip link add test-bridge address b6:83:a2:b3:2f:0e type bride

the bridge id is not set:

# brctl show
bridge name    bridge id        STP enabled    interfaces
bridge1        8000.000000000000    no


It looks like this is caused by br_stp_set_bridge_id never beeing
called. There appear to be many ways to solve this, but not sure what
is the preferred route...

Cheers,

Tom
