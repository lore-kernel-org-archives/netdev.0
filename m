From: David Miller <davem@davemloft.net>
Subject: Re: RPS and forwarding
Date: Sun, 25 Apr 2010 23:28:57 -0700 (PDT)
Message-ID: <20100425.232857.145290769.davem@davemloft.net>
References: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
	<20100426045316.GA21810@gondor.apana.org.au>
	<r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55937
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752398Ab0DZG2w convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 02:28:52 -0400
In-Reply-To: <r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Sun, 25 Apr 2010 22:00:09 -0700

>> Right. =A0The problem is that if you run a distribution kernel on
>> a router with CONFIG_RPS (and hence RFS) enabled, you may suddenly
>> start seeing packet reordering on forwarded traffic due to the
>> presence of local traffic.
>>
>> Can we perhaps add a run-time toggle to disable RFS?
>>
> RFS is not on at run-time by default.  The number of entries in the
> global_rps_sock table needs to be set in sysctl, and the number of
> entries in rps_dev_flow_table needs to be set per RX queue in sysfs.
> You can turn it on for some devices, but not others if that helps.

Right, none of this stuff is on by default.

It might be possible to somehow make the sock table get bypassed for
forwarded traffic, but I can't think of a cheap way to do that at
the moment.
