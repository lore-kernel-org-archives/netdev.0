From: Rami Rosen <roszenrami@gmail.com>
Subject: Net-next-2.6 and net-2.6 repos and git-cloning via http
Date: Tue, 15 Dec 2009 12:04:38 +0200
Message-ID: <b25312890912150204n1ee8e303xe1d165bd90c7c08c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:64665 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757558AbZLOKEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 05:04:40 -0500
Received: by ewy19 with SMTP id 19so293296ewy.21
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 02:04:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Do the net-next-2.6 and net-2.6 repossupport git-clone via http (for
cases when git port, 9418, is blocked ?)

I am trying:
git-clone http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
Initialized empty Git repository in /home/rami/new/net-next-2.6/.git/
fatal: http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git/info/refs
not found: did you run git update-server-info on the server?

also:
git-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
Initialized empty Git repository in /home/rami/new/net-next-2.6/.git/
gives the same result.

(I just want to add that on some other repos, the info/refs does exist,
for example, http://www.kernel.org/pub/scm/virt/kvm/pcbios.git/info/refs,
and I can do git-clone with
http with them, but I really don't know whether this is the reason or
just a wild speculation).

Rgs,
Rami
