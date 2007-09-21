From: Bruce Cole <bacole@gmail.com>
Subject: Re: e1000 driver and samba
Date: Fri, 21 Sep 2007 11:21:54 -0700
Message-ID: <46F40BC2.2000806@gmail.com>
References: <46F302A8.7040008@gmail.com> <780b6f780709210713s62f6d51s90eb0a54cda2a3fb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bacole@gmail.com
To: L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:25650 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbXIUSZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 14:25:19 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1068678wah
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 11:25:19 -0700 (PDT)
In-Reply-To: <780b6f780709210713s62f6d51s90eb0a54cda2a3fb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L F wrote:
> Aha. This doesn't seem to be in mr. Romieu's patch above: should it go
> in on top of that?
>   
His newer

0002-r8169-workaround-against-ignored-TxPoll-writes-8168.patch
does the same thing as the older quoted version, and is also
included in the roll-up patch he pointed you to.

I agree re. performance, and don't want to clutter the thread
realtek issues.  I just wanted to clarify this particular
realtek-samba issue in case it's relevant.  For a long time folks
suspected similar culprits (bad cable, half duplex, etc.) when
it was the driver.  Perhaps you should try doing a ping flood 
between server&client during your test.  That healed the
problem by keeping the queue busy in the realtek case.





