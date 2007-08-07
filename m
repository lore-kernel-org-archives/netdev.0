From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Tue, 07 Aug 2007 08:52:35 -0400
Message-ID: <1186491155.5163.68.camel@localhost>
References: <20070805.232423.21363072.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:58271 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761117AbXHGMwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 08:52:39 -0400
Received: by wr-out-0506.google.com with SMTP id 36so569653wra
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2007 05:52:39 -0700 (PDT)
In-Reply-To: <20070805.232423.21363072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-05-08 at 23:24 -0700, David Miller wrote:

> 
> 3) Attempt to bring NAPI howto as uptodate as is possible for such
>    a rotting document. :)

That doc is out of date on the split of work - it focusses mostly
describing the original tulip which did not mix rx and tx in the
napi_poll(). AFAIK, no driver does that today (although i really liked
that scheme, there is a lot of fscked hardware out there that wont work
well with that scheme). Where are the firemen when you need them? 

Scanning your changes on the drivers for hardware i possess, I dont see
any issues.

cheers,
jamal

