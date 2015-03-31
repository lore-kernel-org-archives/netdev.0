From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ipv6: coding style - comparisons with NULL
Date: Tue, 31 Mar 2015 13:53:38 -0400 (EDT)
Message-ID: <20150331.135338.519327316482059081.davem@davemloft.net>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbbCaRxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:53:41 -0400
In-Reply-To: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Sun, 29 Mar 2015 14:00:03 +0100

> The following patches address some coding style issues only. No
> functional changes and no changes detected by objdiff.
>
> The IPV6 code uses multiple different styles when comparing with
> NULL (I.e. x == NULL and !x as well as x != NULL and x). Generally
> the latter form is preferred according to checkpatch and so this
> changes aligns the code to this style.

Please trim your commit message lines to 80 columns in the future.

It is _extremely_ irritating to see how people type commit messages
into GUI or similar tools, and then expect that the rest of the world
will see the message formatted in the same exact way.

The only reliable way to edit and format commit log messages, so that
everyone sees something consistent, is to do so in a pure plain ASCII
text editor and use newlines to break columns at ~80 columns.

Anyways, I've applied this series, thanks.
