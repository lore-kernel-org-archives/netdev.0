From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 doesn't work
Date: Tue, 3 Apr 2007 23:28:36 +0200
Message-ID: <20070403212836.GA12963@electric-eye.fr.zoreil.com>
References: <87ircdtbkn.fsf@duaron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45089 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945975AbXDCVce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 17:32:34 -0400
Content-Disposition: inline
In-Reply-To: <87ircdtbkn.fsf@duaron.myhome.or.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> I have a r8169 problem, it seems RX doesn't work. To work r8169 for me
> I'm needing to revert the following three commits now, but I don't
> know why.
> 
>     9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2
>     12d86f682e8acad8555718dc7b0082590f2365d0
>     cc9f022d97d08e4e36d38661857991fe91447d68

(oh, the horror...)

> Any idea?

Figuring the last known working kernel version and the first broken one
could help (which hardware ? x86_64 + SMP ?) but I'd appreciate if you
try beforehand the patches at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc5/r8169-20070402

-- 
Ueimor
