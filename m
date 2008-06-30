From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 6/8] netfilter: fix string extension for case insensitive pattern matching
Date: Mon, 30 Jun 2008 12:32:18 -0700
Message-ID: <b25c3fa70806301232w41617d02qa53292f5982c25d0@mail.gmail.com>
References: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
	 <alpine.LNX.1.10.0806210957140.28924@fbirervta.pbzchgretzou.qr>
	 <b25c3fa70806301144x4cd521dfpdd8bb6ef13b8466@mail.gmail.com>
	 <alpine.LNX.1.10.0806302108290.30639@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>
To: "Jan Engelhardt" <jengelh@medozas.de>,
	"Patrick McHardy" <kaber@trash.net>, "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:5307 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbYF3TcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 15:32:21 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1837133rvb.1
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2008 12:32:20 -0700 (PDT)
In-Reply-To: <alpine.LNX.1.10.0806302108290.30639@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/6/30 Jan Engelhardt <jengelh@medozas.de>:
> Right, since we copy eader files anyway, we can just make it uint8_t flags
> without the union.

I like it :-)
Patrick, Thomas, If you want I'll send this fix with version checking patch.

>
>>But I guess we should do version checking between user-space and
>>kernel more strictly whatever.
>
> That is what we have '.revision' in xt_match/xt_target for.
> In this case however it should be fine with just flags.
>
