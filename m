From: Lal <learner.kernel@gmail.com>
Subject: RPS patch questions
Date: Wed, 25 Aug 2010 18:05:41 +0530
Message-ID: <AANLkTikXLwDA5cTevWiBRf+6BvZFEs+YSVqZk7wJLEjq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37498 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531Ab0HYMfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 08:35:42 -0400
Received: by eyg5 with SMTP id 5so197126eyg.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 05:35:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am evaluating RPS patch from Tom Herbert. I have some questions
regarding this patch.

1. Can __smp_call_function_single be called from bottom half handler?
I presume, yes.

2. I am working on 2.6.21 kernel which have neither
__smp_call_function_single nor smp_call_function_single. I used
smp_call_function_single from some other kernel version but this too
can not be called from bottom half handler (just like
smp_call_function). Did somebody try to write such function for 2.6.21
(or older kernel) which can be called from bottom halves?

3. One option I've is to upgrade to 2.6.27 kernel which has
__smp_call_function_single. I see a comment that this function must
not be called with interrupt disabled. Does it mean it can be called
from bottom half handler?

Thanks
Lal
