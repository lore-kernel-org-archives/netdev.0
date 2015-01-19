From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Mon, 19 Jan 2015 17:49:58 +0100
Message-ID: <6534595.xliyeOG6D7@storm>
References: <1719052.SGOfRAJhfQ@storm> <8088599.PZmG8U31O2@storm> <1421335532.11734.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7Bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:40592 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbASQuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 11:50:02 -0500
In-Reply-To: <1421335532.11734.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 15. January 2015 07:25:32 Eric Dumazet wrote:
> On Thu, 2015-01-15 at 15:58 +0100, Thomas Jarosch wrote:
> > A colleague mentioned to me he saw the "Hardware Unit Hang" message
> > every
> > few days even running on kernel 3.4 (without your patch). Basically I'm
> > testing now if that's still the case with 3.19-rc4+ or not.
> > 
> > I'm all for fixing the root cause. I'm just interested if the e1000e
> > hang can even be triggered when using a max frag page size of 4096.
> > So far it transferred 751.6 GiB without a hiccup.
> 
> You told it was forwarding setup.
> 
> 1) What is the NIC receiving traffic.
> 2) What happens if you disable GRO on it ?

one more interesting thing happened: On one production machine,
again an Intel DH61CR board, the issue was triggered even with TSO disabled.
My colleague tried to disable GRO + GSO on the e1000e adapter, too,
though not on the other interfaces.

It's strange the issue appears with TSO disabled,
that worked for three other production level machines.

We've emergency-installed the "4096" max frag page size workaround
for now as fifty people were a bit unhappy without network access... :D

Cheers,
Thomas
