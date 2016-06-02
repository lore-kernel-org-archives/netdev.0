From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 5/6] tftpd: fix syslog setup
Date: Thu, 2 Jun 2016 17:31:50 +0900
Message-ID: <574FEEF6.1080109@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-5-git-send-email-vapier@gentoo.org>
 <574F958D.4060409@miraclelinux.com> <20160602043308.GM7717@vapier.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36719 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264AbcFBIbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 04:31:53 -0400
Received: by mail-pa0-f53.google.com with SMTP id te7so781341pab.3
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 01:31:53 -0700 (PDT)
In-Reply-To: <20160602043308.GM7717@vapier.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> On 02 Jun 2016 11:10, YOSHIFUJI Hideaki wrote:
>> Mike Frysinger wrote:
>>> Commit d81a44625b04d487c895473aa77af13420b7afdd added support for checking
>>> the set*id calls, but would call syslog() before it had called openlog().
>>> Move the call up earlier to fix that.
>>
>> Please describe what it really fixes.
> 
> i already did: you need to call openlog before calling syslog, but the
> code here very clearly doesn't.  if you read the commit i referenced,
> and the all <25 lines of context here, it should be pretty obvious the
> code is wrong.
> -mike
> 

OK, applied. Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
