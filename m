From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 13:49:34 -0400
Message-ID: <525ED1AE.7050101@mojatatu.com>
References: <525C62D5.3090004@mojatatu.com> <20131014144156.6dc52a78@nehalam.linuxnetplumber.net> <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:57619 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761275Ab3JPRtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 13:49:36 -0400
Received: by mail-yh0-f48.google.com with SMTP id f64so252997yha.21
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 10:49:35 -0700 (PDT)
In-Reply-To: <525EC8AF.6000902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/13 13:11, Vlad Yasevich wrote:
> On 10/16/2013 09:54 AM, Jamal Hadi Salim wrote:
>
>
> This was to display or filter out virtual function data.
>

Stephen explained - and it seems to make sense (working around
netlink weaknesses). It could be made more generic.


> I probably doesn't need to use this as we want the bridge data, not the
> VF data stored as part of PF interface.
>

I think we need some filtering in the kernel. As it stands today,
unfortunately you get everything ;-> I was suprised at the amount of
data i get from the kernel these days when i ask for a simple netdev
info (I think no less than 1K per netdev; everything from /proc entries
from some bread crumbs i dont see any use for.

>> - get attributes for all bridge ports for bridge br-blah (not there)
>> you could also use the ifindex of br-blah here instead
>
> This would be usefull.
>

Its a usability improvement.
We still have the ifi->ifindex available. It could be used to signal
which bridge device's ports i want.
But then i get _all_ the ports for that bridge.

>
>
> You can already do this with:
>
>      ip link set dev ethX master brX
>

Yes, I know - it sucks from a usability pov.

cheers,
jamal
