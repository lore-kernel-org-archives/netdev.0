From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
   in back trace (regression)
Date: Thu, 23 Jul 2009 21:11:22 +0200
Message-ID: <4A68B5DA.5000307@gmail.com>
References: <20090723000100.d74d6b1c.akpm@linux-foundation.org>	<20090723.091523.180916751.davem@davemloft.net>	<20090723105141.5272aee1.akpm@linux-foundation.org> <20090723.105344.244636270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, for.poige+bugzilla.kernel.org@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:45678 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbZGWTLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 15:11:49 -0400
Received: by bwz28 with SMTP id 28so1021488bwz.37
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 12:11:48 -0700 (PDT)
In-Reply-To: <20090723.105344.244636270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 07/23/2009 07:53 PM:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 23 Jul 2009 10:51:41 -0700
> 
>> I wouldn't have thought that pppoe would be affected by tty changes?
>>
>> As opposed to pppotty :)
> 
> Good point.  So it's unlikely any of the changes we're discussing
> will influence this bug.
 

Here is a link showing around pppoe problem quite similar to
the one fixed later in pty.c by Alan Cox, so IMHO the current
2.6.31-rc is worth trying.

From: Dave Young <hidave.darkstar@gmail.com>
Subject: BUG: sleeping function called from invalid context at 
	kernel/mutex.c:280
Date: Fri, 19 Jun 2009 10:36:13 +0800

http://permalink.gmane.org/gmane.linux.network/131166

Jarek P.
