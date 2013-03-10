From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Sun, 10 Mar 2013 06:05:37 +0100
Message-ID: <1362891937.4051.25.camel@edumazet-glaptop>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	 <1362888229.4051.2.camel@edumazet-glaptop>
	 <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Vimal <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:32956 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab3CJFFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 00:05:41 -0500
Received: by mail-ea0-f182.google.com with SMTP id q15so713620ead.13
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 21:05:39 -0800 (PST)
In-Reply-To: <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-09 at 20:53 -0800, Vimal wrote:
> Ok, do you have suggestions on how to do this?  Maybe a better way to
> do this would be to introduce an additional "multipler" option for
> rates, which is set to 1 as default, so actual rate can be computed as
> multipler * rate supplied.

How an old program, in binary form, will automatically knows it has to
change its behavior to use an inexistent field ?

I can use an old distro, and update kernel to upstream kernel, it must
continue to work.
