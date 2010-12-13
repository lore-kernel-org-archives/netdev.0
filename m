From: Rui <wirelesser@gmail.com>
Subject: use struct sock->sk_protinfo store private data?
Date: Mon, 13 Dec 2010 15:32:58 +0800
Message-ID: <AANLkTimFyE+bSgDsqOioWwuDjunCA8KggJ-SQiN_WGdu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:32884 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab0LMHc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 02:32:58 -0500
Received: by pxi20 with SMTP id 20so1580159pxi.10
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 23:32:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

I saw one in-house kernel module use struct sock->sk_protinfo to store
a private data
is it safe? will other parts use it?

quoted from net/sock.h

  *	@sk_protinfo: private area, net family specific, when not using slab

thanks
rui
