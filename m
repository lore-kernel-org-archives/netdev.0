From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils 5/6] tftpd: fix syslog setup
Date: Thu, 2 Jun 2016 11:10:21 +0900
Message-ID: <574F958D.4060409@miraclelinux.com>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-5-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33947 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbcFBCK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 22:10:26 -0400
Received: by mail-pf0-f180.google.com with SMTP id 62so24871783pfd.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 19:10:25 -0700 (PDT)
In-Reply-To: <1464752905-10347-5-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> Commit d81a44625b04d487c895473aa77af13420b7afdd added support for checking
> the set*id calls, but would call syslog() before it had called openlog().
> Move the call up earlier to fix that.

Please describe what it really fixes.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
