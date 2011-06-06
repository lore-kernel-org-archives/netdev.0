From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Sun, 05 Jun 2011 22:15:37 -0700 (PDT)
Message-ID: <20110605.221537.899061768025493519.davem@davemloft.net>
References: <1306363336-13614-1-git-send-email-maheshb@google.com>
	<20110604.133438.1450652272927306428.davem@davemloft.net>
	<20110606035808.GA28858@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, therbert@google.com,
	mirqus@gmail.com, shemminger@vyatta.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab1FFFPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 01:15:48 -0400
In-Reply-To: <20110606035808.GA28858@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 6 Jun 2011 06:58:08 +0300

> I've been thinking about this as well. It turns out most
> things above can be done with the spatch (aka coccinelle) tool.
> But I think the largest problem is what to do with multiple-feature
> macros such as NETIF_F_GSO_SOFTWARE.
> 
> If we keep them an 'or' of bits, we more or less commit to
> an implementation that can represent them all in a single
> constant.
> 
> I played with variadic macros but could not come up with something
> that does not generate a lot of code.

Since the GSO accessors deal with mutliple bits, you can create
special GSO specific interfaces to manipulate them.

