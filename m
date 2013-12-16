From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: Fw: [Bug 66691] New: iproute2: macvlan: Wrong root device shown
 if in different netns
Date: Mon, 16 Dec 2013 11:38:19 +0100
Message-ID: <CAGXE3d81W+QG0kO_7P+36YkyNsRNup+MGq-1NQE0TxKMtBiJ4g@mail.gmail.com>
References: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:63984 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab3LPKiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:38:20 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so6181081iej.40
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 02:38:20 -0800 (PST)
In-Reply-To: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 6, 2013 at 9:05 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> This isn't a iproute2 bug, it is only reporting what the kernel tells it

But iproute2 assumes that the ifindex is unique within all net
namespaces. This isn't true anymore
after commit aa79e66eee5d525e2fcbd2a5fcb87ae3dd4aa9e9 "net: Make
ifindex generation
per-net namespace".

However, in order to do the right thing iproute2 would have to know
the ifindex of the
link device _and_ its associated netns.

Not sure how to deal with that ...
Helmut
