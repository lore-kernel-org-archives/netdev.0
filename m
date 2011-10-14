From: roy.qing.li@gmail.com
Subject: [Bug] skb truesize does not update properly in many place
Date: Fri, 14 Oct 2011 13:33:01 +0800
Message-ID: <1318570381-4731-1-git-send-email-roy.qing.li@gmail.com>
Cc: roy.qing.li@gmail.com
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33809 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab1JNFdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 01:33:16 -0400
Received: by wyg34 with SMTP id 34so2610611wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 22:33:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric Dumazet:

I see you are correcting the wrong skb truesize, I found the
same problem exists in many forms and many places, like:

After calling skb_fill_page_desc(), what should be updated 
to truesize.

pskb_expand_head(), __pskb_pull_tail()... do not update the
truesize.

...

-RongQing.Li
