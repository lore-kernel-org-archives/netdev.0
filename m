From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Vlan interface nuisance
Date: Tue, 3 Mar 2009 06:41:49 +0000
Message-ID: <20090303064149.GA4154@ff.dom.local>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com> <49AC545E.3090708@trash.net> <20090302223011.GA3388@ami.dom.local> <49AC6D24.1030605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:61883 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757341AbZCCGl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:41:56 -0500
Received: by bwz26 with SMTP id 26so2231568bwz.37
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2009 22:41:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49AC6D24.1030605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 12:35:00AM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Mon, Mar 02, 2009 at 10:49:18PM +0100, Patrick McHardy wrote:
>>> The binding is displayed when listing interfaces. This hole
>>> argument is silly, if you want a particular name, just specify
>>> it. The current naming schemes are entirely based on information
>>> that you have to specify anyways.
>>
>> Just for the record, I don't agree with calling "this" argument silly
>> just like it was with "that" argument. Actually, I think they are
>> both so "right" that I've changed my mind and think it's great each
>> tool does it differently...
>
> I'm not sure whether I'm supposed to understand this, so I'm going
> to respond with something useful unrelated to naming user resources
> that every virtual device author should know (and that seems to be
> not well known):
>
> Every virtual device bound to a different device should set the
> dev->iflink field to the ifindex of the device bound to. This
> makes every device related netlink message include this relation.
> If the binding is already known at device-creation time and
> relevant for the virtuals device's existance, this must be done
> in the ->init callback to make sure its already included in the
> first netlink creation message to avoid inconsistent information.
>
> This is the also the prefered way device bindings should be
> signaled to the kernel, and at least iproute and libnl are
> aware of this in both directions. And to get back to the main
> point of this discussion:
>
> # ip l l
> 4: vlan0@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
>     link/ether 92:2a:4f:ae:dc:29 brd ff:ff:ff:ff:ff:ff

Yes, very interesting arguments for another disussion... But if we're
talking about naming than you seem to ignore what Lennart, Ben, Denys
and probably Stephen said about their preferred way, and I think it
matters, because if they had problems with understanding this change
I can only imagine what "common users" would say without knowing all
this technical rationale (which IMHO is disputable too - names  are
for people).

Jarek P.
