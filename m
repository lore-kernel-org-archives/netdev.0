From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atm: deal with setting entry before mkip was called
Date: Mon, 14 Sep 2015 10:07:14 -0700
Message-ID: <1442250434.14284.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442245730-31575-1-git-send-email-sasha.levin@oracle.com>
	 <1442249450.14284.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55F6FD2A.7080004@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36101 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbINRHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 13:07:16 -0400
In-Reply-To: <55F6FD2A.7080004@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-09-14 at 13:00 -0400, Sasha Levin wrote:

> I've tried to be consistent with a similar check within clip_mkip() and
> clip_setentry():
> 
>         if (!vcc->push)
>                 return -EBADFD;
> 
> So calling clip_setentry() before clip_mkip() would also give you -EBADFD.
> 

Okay, but -EBADF is not the same than -EBADFD
