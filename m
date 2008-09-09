From: "Zsolt SZALAI" <zs.szalai@gmail.com>
Subject: [IPSEC] confused about IPSEC_MANUAL_REQID_MAX
Date: Tue, 9 Sep 2008 13:00:25 +0200
Message-ID: <dffc28000809090400l9617cfejc2607c6b3767417@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:35803 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbYIILA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 07:00:26 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1978331wfd.4
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 04:00:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

ipsec.h defines IPSEC_MANUAL_REQID_MAX as 0x3fff (16383) and only
af_key.c, the PF_KEY implementation uses that. When configuring a
policy with a higher reqid, the kernel drops the manually given reqid
and generates a new one.
Contrarily, XFRM allows one to create policies with higher reqid-s and
this is some inconsistency i guess.
I could not find any note on generating reqids in the pf_key rfc. From
where is that come from? Is it really necessary?

As XFRM allows, is it safe to increase this value or even bypass the
checking of the reqid beeing higher than that?

Thanks,
Zsolt Szalai
