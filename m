From: Felipe Dias <felipediassss@gmail.com>
Subject: skb->tstamp == 0.00000 ?
Date: Sat, 19 Nov 2011 18:18:51 -0300
Message-ID: <CAJX4=r1nz4Wq00tmJKUsJNLb41Bh4=-V1ixLcS05mXm0tpek9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60100 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab1KSVSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2011 16:18:52 -0500
Received: by bke11 with SMTP id 11so4871405bke.19
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2011 13:18:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi..

Please let me know if this isnt right list to this kind of question.

I'm registering a new protocol handler with dev_add_pack. I would like
to know only the difference between timestamp on skb->tstamp and the
time of reception by my module.

So I do:
----
struct timeval time_skb, time_module;
do_gettimeofday(&time_module):
skb_get_timestamp(skb, &time_skb);
---

And time_skb.tv_sec and time_skb.tv_usec are equal to 0;

I'm doing some wrong ?

Best regards,
Felipe
