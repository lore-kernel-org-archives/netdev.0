From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] via-rhine: hardware VLAN support
Date: Fri, 5 Nov 2010 11:31:56 -0700
Message-ID: <AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
References: <20101105104303.GA8325@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33002 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab0KESb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 14:31:57 -0400
Received: by wyb36 with SMTP id 36so1364770wyb.19
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 11:31:56 -0700 (PDT)
In-Reply-To: <20101105104303.GA8325@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 5, 2010 at 3:43 AM, Roger Luethi <rl@hellgate.ch> wrote:
> This patch adds VLAN hardware support for Rhine chips.
>
> The driver uses up to 3 additional bytes of buffer space when extracting
> 802.1Q headers; PKT_BUF_SZ should still be sufficient.
>
> The initial code was provided by David Lv. I reworked it to use standard
> kernel facilities. Coding style clean up mostly follows via-velocity.

This uses the old interfaces for vlan acceleration.  We're working to
switch drivers over to use the new methods and the old ones will be
going away in the future.  It would be great if we can avoid adding
more code that uses those interfaces.
