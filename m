From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 11:30:34 -0800
Message-ID: <1356118234.21834.7800.camel@edumazet-glaptop>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	 <1356114663.21834.7697.camel@edumazet-glaptop>
	 <1356115931.21834.7745.camel@edumazet-glaptop>
	 <CALvgte-=v=bRnQ2HPDxyqxBOjD6DXp_BUySW6Hm7h+81M+RYMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:39666 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab2LUTag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 14:30:36 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so2223162dam.4
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 11:30:36 -0800 (PST)
In-Reply-To: <CALvgte-=v=bRnQ2HPDxyqxBOjD6DXp_BUySW6Hm7h+81M+RYMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 14:13 -0500, Zhiyun Qian wrote:
> That seems like a good idea. I am not sure how it is implemented
> though. Is it a new feature of Linux? Would you mind sending some
> pointers for this?

I dont have details, I only remember having to fix a memory allocation
error that was hitting Chrome users.


http://comments.gmane.org/gmane.linux.network/249535


Julien said at that time :

<quote>
It happens when users start Chrome. Chrome will create one new network
NS (for the sandbox).

This has been used for a few years now, but we had our first report in
January of this year and we've been getting a few reports very
recently at a rate that is starting to worry me (crbug.com/110756).

Thanks a lot for helping with this!

Julien
</quote>
