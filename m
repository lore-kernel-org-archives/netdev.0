From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH iputils v2] ping: always accept . delimiter with -i number
 parsing
Date: Thu, 2 Jun 2016 17:28:55 +0900
Message-ID: <574FEE47.7030402@miraclelinux.com>
References: <1464752905-10347-6-git-send-email-vapier@gentoo.org>
 <1464842814-30690-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36233 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbcFBI3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 04:29:00 -0400
Received: by mail-pf0-f171.google.com with SMTP id f144so28815517pfa.3
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 01:29:00 -0700 (PDT)
In-Reply-To: <1464842814-30690-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mike Frysinger wrote:
> Always allow #.# format for the -i flag even when the current locale
> uses a different separator.  Locale de_DE which uses #,# normally.
> 
> Simple testcase:
> $ make USE_IDN=1
> $ LANG=de_DE.UTF8 ./ping -i 0.5 localhost
> $ LANG=de_DE.UTF8 ./ping -i 0,5 localhost
> 
> Reported-by: Sergey Fionov <fionov@gmail.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---

Applied, thanks.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
