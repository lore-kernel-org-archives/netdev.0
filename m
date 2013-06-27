From: David Shwatrz <dshwatrz@gmail.com>
Subject: fa_type and fib_info - a question
Date: Thu, 27 Jun 2013 22:16:12 +0300
Message-ID: <CAJJAcoeMwSTbSPCQYJa8e5ZNVqWRkP63PzLd3S2bAquD5uZk4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:43237 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab3F0TQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 15:16:13 -0400
Received: by mail-vb0-f48.google.com with SMTP id w15so1000940vbf.21
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 12:16:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Can anybody assist on this IPv4 question:
Why does fib_alias contain an fa_type member and also fib_info contain
a fib_type member?  A fib_alias must refer to some fib_info object via
the fa_info pointer. Are there cases when fa_type can differ from
fib_type? or is it so only for some legacy reason?

DS
