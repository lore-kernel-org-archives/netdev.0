From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v2 net-next] net: remove useless if check from register_netdevice()
Date: Thu, 13 Feb 2014 10:28:53 -0800
Message-ID: <CAHA+R7PENByJxTc2c09NCJX8q_EHgk7vM1vV=5PxqWHdMe+M9g@mail.gmail.com>
References: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
	<CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
	<CAOJe8K2iTsv-HUEotjwpc7s9LMEU6+nMfK5VWWF0tcMLhYBS6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:65325 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbaBMS2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 13:28:54 -0500
Received: by mail-lb0-f180.google.com with SMTP id n15so8326333lbi.25
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 10:28:53 -0800 (PST)
In-Reply-To: <CAOJe8K2iTsv-HUEotjwpc7s9LMEU6+nMfK5VWWF0tcMLhYBS6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 9:15 AM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> All of the users of ndo_init return negative error code on error path.
> Only staging stuff tries to use positive codes like octeon ethernet
> which does request_irq inside ndo_open...
>

You should put this explanation in the changelog.
