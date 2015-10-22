From: Naji M Abdulla <najimohamed2004@gmail.com>
Subject: XFRM Policy lookup in flowcache
Date: Thu, 22 Oct 2015 10:55:59 -0700
Message-ID: <CAABA98rjqzCZqHJehfHF9ASX5NwYVncMdVgzJrrqsknXyh5DGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34572 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964912AbbJVR4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:56:00 -0400
Received: by wikq8 with SMTP id q8so43453413wik.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 10:55:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have a question regarding speeding up xfrm policy lookup in flow cache.

We are working on a product where  3 policies (in,fwd and out) are
setup per tunnel.

Tunnels comes up and down all the time, so the policy data base will
be keep changing.

Looks like there is an impact in performance since every time policy
database is changed, policies in flow cache gets invalidated. This
eventually results in almost all lookups going to policy database.

Is there any mechanism to get around this to get faster policy lookup?

thanks

--naji
