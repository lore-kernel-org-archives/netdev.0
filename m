From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Fw: [Bug 75571] New: using tc action mirred results BUG at net/core/skbuff.c:119
Date: Sun, 11 May 2014 07:29:53 -0400
Message-ID: <536F5F31.4060008@mojatatu.com>
References: <20140506081628.1626ff94@nehalam.linuxnetplumber.net>	<CAHA+R7NX639wxkvvrqP=ogeiAwDeJYDnFp_z_VqB3yqh8KLjFA@mail.gmail.com>	<536B58D7.2070009@mojatatu.com> <CAHA+R7OG0qqr4Q2cFomY0CKH6DP+J==ii_G--d6FzcTScB6iEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>, d77190@mail.ru
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34251 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758044AbaEKLaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 07:30:18 -0400
Received: by mail-ie0-f173.google.com with SMTP id rp18so5886693iec.18
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 04:30:17 -0700 (PDT)
In-Reply-To: <CAHA+R7OG0qqr4Q2cFomY0CKH6DP+J==ii_G--d6FzcTScB6iEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/14 14:31, Cong Wang wrote:

> It's an old kernel, 3.2.58. :-/
>

The email wasnt clear.

> Please try to reproduce it on the latest kernel if possible.

Also - try what i said in ifconfig up interfaces last and
see if that resolves it (that would still point to some
lock/rcu changes that may have happened earlier than your
changes; i.e something is no longer protecting user space
from data path activity).

cheers,
jamal
