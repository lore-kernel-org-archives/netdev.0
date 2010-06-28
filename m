From: sbs <gexlie@gmail.com>
Subject: Re: IGB driver upgrade
Date: Tue, 29 Jun 2010 02:02:18 +0400
Message-ID: <AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>
References: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41679 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab0F1WCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 18:02:20 -0400
Received: by bwz1 with SMTP id 1so414585bwz.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 15:02:18 -0700 (PDT)
In-Reply-To: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys.

Is it possible to upgrade intel gigabit adapter's e1000 driver to
2.2.9? This is the latest version according to Intel website.


I've got a problem with 2.1.0-k2 drivers statically compiled into kernel.

Surely I can download drivers from intel and compile it as module, but
I need to compile it statically
Intel drivers do not provide sources for static compilation :(

Is it possible to upgrade drivers to igb-2.2.9 in the source tree and
allow the static compilation of them?

Because having 2.1.0-k2 we experience some strange random freezes with
network interface which can be fixed only by restarting network.

2.2.9 module has no such problems but we need to use static kernels
according to our policy.
