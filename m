From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: ALX driver fails to resume from suspend on 3.11
Date: Wed, 25 Sep 2013 13:13:57 -0400
Message-ID: <CA+5PVA4Lify9WdCdNzXDHLsf4Q==sUHkAdFXBz7m3W-Cm678hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: James Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:32957 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab3IYRN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 13:13:58 -0400
Received: by mail-wg0-f46.google.com with SMTP id k14so6338132wgh.13
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 10:13:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

We've had a couple reports [1] of the ALX module causing issues on
resume from suspend.  The reporters say their logs are flooded with
messages like:

alx 0000:04:00.0: invalid PHY speed/duplex: 0xffff

This was working fine in the 3.10 kernel.  Does anyone have any ideas
why this would be occurring now?

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=1011362
