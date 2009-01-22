From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Subject: RE: [PATCH] IPv6 multicast routing
Date: Thu, 22 Jan 2009 15:30:38 -0800
Message-ID: <21C34AA2609529459A85739E2952066904A9670D@XCH-NW-9V1.nw.nos.boeing.com>
References: <20090120200248.GA13928@boeing.com> <20090121.100431.126366547.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:52675 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233AbZAVXaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 18:30:55 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090121.100431.126366547.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 10:04:31AM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:

> >   - Enable/disable IPv6 multicast forwarding on the corresponding
> >     interface when a routing daemon adds/removes a multicast virtual
> >     interface.
:
> However, I believe configuring forwarding is user's responsibility
> and I'm not in favor of managing mc_forwarding automatically.
>
> If we go your way, we need to make the proc interface read-only, but
> you know, they will become non-"conf" interface. :-(
> And, well, we will introduce another possible overflow/underflow here...
>
> Another thought was to allow non-VIF routing settings (or manual settings).
>
> So, I decided to drop that bits.

Thanks for looking it over.

I think your approach to handling mc_forwarding makes sense, although
it differs from the IPv4 behavior.  In any case, it looks like the
current IPv4 and IPv6 multicast routing code does not consider an
interface's mc_forwarding value at all.

  Tom
