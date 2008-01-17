From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 08:27:14 +0200
Message-ID: <478EF542.1010702@iki.fi>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:43419 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbYAQG0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 01:26:01 -0500
Received: by fg-out-1718.google.com with SMTP id e21so556892fga.17
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 22:26:00 -0800 (PST)
In-Reply-To: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> jamal <hadi@cyberus.ca> wrote:
>> There are two issues that are inter-mingled in there. The most important
>> is pf_key not being robust on dump. The other being the accurracy of
> 
> IMHO doing significant work on af_key is a waste of time.  It has no
> advantages at all over xfrm_user since neither is portable.  So we
> should discourage people from using af_key wherever possible.

I don't know about netlink. But pfkey works in *BSD too and it is RFC'd.
So I'd say pfkey might be a bit more portable. Though netlink is definitely
more robust and extensive.

Cheers,
  Timo


