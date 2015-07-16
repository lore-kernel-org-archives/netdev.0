From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] rocker: forward packets to CPU when port is
 joined to openvswitch
Date: Wed, 15 Jul 2015 23:40:31 -0700
Message-ID: <CAE4R7bCBaMZKAhUbW4MC3Z5hmic2kUZuBn94zB6j+kY1Z2piag@mail.gmail.com>
References: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33308 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbbGPGkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 02:40:51 -0400
Received: by oige126 with SMTP id e126so44342629oig.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 23:40:50 -0700 (PDT)
In-Reply-To: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 6:39 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Teach rocker to forward packets to CPU when a port is joined to Open vSwitch.
> There is scope to later refine what is passed up as per Open vSwitch flows
> on a port.
>
> This does not change the behaviour of rocker ports that are
> not joined to Open vSwitch.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>

Now, OVS flows on a port.  Strange enough, that was the first RFC
implementation for switchdev/rocker where we hooked into ovs-kernel
module and programmed flows into hw.  We pulled all of that code
because, IIRC, the ovs folks didn't want us hooking into the kernel
module directly.  We dropped the ovs hooks and focused on hooking
kernel's L2/L3.  The device (rocker) didn't really change: OF-DPA
pipeline was used for both.  Might be interesting to try hooking it
again.
