From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: Fw: [Bug 66691] New: iproute2: macvlan: Wrong root device shown
 if in different netns
Date: Mon, 16 Dec 2013 11:47:14 +0100
Message-ID: <CAGXE3d9hS4CBKTiKpn=_K3U6NPE+WzR4oFD1D3YtFb2NqzcxsA@mail.gmail.com>
References: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net>
	<CAGXE3d81W+QG0kO_7P+36YkyNsRNup+MGq-1NQE0TxKMtBiJ4g@mail.gmail.com>
	<52AED8F5.5030804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:62995 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab3LPKrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:47:15 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so6169092ief.20
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 02:47:14 -0800 (PST)
In-Reply-To: <52AED8F5.5030804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 11:41 AM, Pavel Emelyanov <xemul@parallels.com> wrote:
> On 12/16/2013 02:38 PM, Helmut Schaa wrote:
>> On Fri, Dec 6, 2013 at 9:05 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>> This isn't a iproute2 bug, it is only reporting what the kernel tells it
>>
>> But iproute2 assumes that the ifindex is unique within all net
>> namespaces. This isn't true anymore
>> after commit aa79e66eee5d525e2fcbd2a5fcb87ae3dd4aa9e9 "net: Make
>> ifindex generation
>> per-net namespace".
>>
>> However, in order to do the right thing iproute2 would have to know
>> the ifindex of the
>> link device _and_ its associated netns.
>>
>> Not sure how to deal with that ...
>
> Helmut, what would you expect to see from "ip netns exec myns ip link"
> in case there were no device with ifindex 2 in the myns netns?

No idea, maybe something like "mac0@unknown" would be enough to express
that the link dev is not available within this netns.

My point was that it is confusing to show a clearly wrong link device.

Helmut
