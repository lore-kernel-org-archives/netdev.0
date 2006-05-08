From: "Wong Edison" <hswong3i@gmail.com>
Subject: Re: [PATCH] TCP congestion module: add TCP-LP supporting for 2.6.16.14
Date: Tue, 9 May 2006 01:50:36 +0800
Message-ID: <3feffd230605081050x104461fcj76f2821cfc311a6e@mail.gmail.com>
References: <3feffd230605062232m1b9a3951h6d21071cdacc890f@mail.gmail.com>
	 <20060508112915.GB4162@ucw.cz>
	 <20060508.104322.58430929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: pavel@suse.cz, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:22107 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932477AbWEHRuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 13:50:37 -0400
Received: by py-out-1112.google.com with SMTP id f28so1356142pyf
        for <netdev@vger.kernel.org>; Mon, 08 May 2006 10:50:37 -0700 (PDT)
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060508.104322.58430929.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Or, just include it, and select it with the TCP_CONGESTION socket
> option when you want it.  Sorry, this does require app modifications.

i would like to have more information about this
so within the app
after create the socket
then call setsockopt (!?)
to set the TCP_CONGESTION into "lp" (in my case) ??

is that means the socket's congestion algorithm will then be what i set ??
in this socket within this app only ??

how about the socket create by "accept" ??
it will still use the default ?? or as listen socket ??

thanks
