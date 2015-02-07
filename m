From: ronald pina <pinaronald@gmail.com>
Subject: Implementing Deficit Round Robin for different irtual interfaces
Date: Sat, 7 Feb 2015 12:52:38 +0100
Message-ID: <CAONBAaeKZNCv42a+HY4TtXtYxnAr6-fX1GXEndKJ=r3nZ-1LhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:47416 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340AbbBGLwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 06:52:39 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so8009904igb.2
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 03:52:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I am working for my Msc thesis on computer engineering,  my primary
goal is to introduce scheduling with priorities over different
networking interfaces, it can be very valuable on virtual machines
like Xen and as far as i have studied, Xen is scheduling the virtual
network interfaces  in round-robin fashion, i would like to improve
this and to use Deficit Round Robin, I think the better way is to
integrate the DRR in tc  and   to make the scheduling decisions based
on virtual network interfaces which belongs to different guests as
shown from the diagram in atach.

I would like to ask which function on source code may be a starting
point to realize that kind of scheduling? What are the opportunities
to involve the DRR as a standard scheduler in tc for later use?

Kind regards
Ronald
