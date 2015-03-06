From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: I can tell no FIB
Date: Thu, 5 Mar 2015 21:34:46 -0800
Message-ID: <CAE4R7bCNjmUcUR0pBiknvbF=YR9i=CDZ8CQ4OVpy3KNFhgYSxw@mail.gmail.com>
References: <54F8D249.4080404@gmail.com>
	<CAE4R7bB1Z_gBbaUQLXz2FRS3SSVZp__n-PNnGfX16-Apscf=YA@mail.gmail.com>
	<54F8F2DB.5070901@gmail.com>
	<20150305.222028.124409116923713198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:38660 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbbCFFer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:34:47 -0500
Received: by qgdz60 with SMTP id z60so10436909qgd.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:34:47 -0800 (PST)
In-Reply-To: <20150305.222028.124409116923713198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 7:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Thu, 05 Mar 2015 16:20:43 -0800
>
>> Well the last batch of patches are out there, but there isn't any rush
>> on them.  If need be Dave can just leave them in review until we get the
>> thumbs up or down on the v4 changes since I think you and I are probably
>> the only two patching that region for now.  I suspect the changes
>> shouldn't be as bad as the past patches have been since most of it is
>> just reworking structures and updating the resize code.
>
> Scott just tell me what you want me to do, I can hold off on
> Alex's current series while you put v4 of your stuff together.

I just sent v4.  I need Alex to look over my fib changes.  My testing
didn't hit any problems, but lots of things are moving right where I
was making some insertions and I want to make sure it's clean from a
coding standpoint and also clean from a calling-context standpoint.

Also Alex, can you run my v4 patches on your benchmark setup?  You'll
not have rocker so nothing is getting offloaded, but I wanted to see
if your benchmarks show any degradation from your baseline, for route
insertions and deletions.  There is a per-route cost associated with
my changes, but I'm hoping the costs are negligible.  Please run two
tests: one with CONFIG_NET_SWITCHDEV=y and one with
CONFIG_NET_SWITCHDEV=n.  Thanks Alex!

And thanks Dave for pushing me along on v4.

-scott
