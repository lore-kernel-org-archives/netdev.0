From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: high rate injection and fragmentation
Date: Mon, 9 Feb 2009 18:09:01 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902091806510.31742@wrl-59.cs.helsinki.fi>
References: <3f847c820902090720w98e2ca8pc66f55716c030194@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-277559276-1234195741=:31742"
Cc: netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?=" <rauhersu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60189 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620AbZBIQJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 11:09:03 -0500
In-Reply-To: <3f847c820902090720w98e2ca8pc66f55716c030194@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-277559276-1234195741=:31742
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 9 Feb 2009, Raúl Hernández wrote:

> I am trying to understand the behavior of the IP stack regarding
> fragmentation when injecting at high speed ratio : so far I am seeing
> that TCP starts multiplexing the application level protocol (in my
> case, diameter: previously 1 diameter message = 1 TCP message, when
> the rate increases, multiple diameter messages are coalesced in one
> TCP messages - similar to a Nagle control -).
> 
> At that very moment is when we start finding issues regarding packet
> length checking with ethereal: frames start growing due the multiplex
> above and ethereal shows captured packets >3000 bytes ! (IP total
> lenght makes sense as well according to that figure). The thing is
> that I am working under ethernet law (1500 bytes) and I have checked
> through iproute this is the MTU set for the link (neither
> DONT_FRAGMENT ip options for the socket regarding nor MTU
> modifications have been introduced) so my understanding is that no
> packet > 1500 bytes should be allowed with my configuration (would
> need fragmentation).
> 
> Checking the IP header with ethereal, "dont fragment" is set and
> "fragment offset"=0. IOW, It seems that IP is not fragmenting the
> packet although > MTU which I am not able to understand.
> 
> Any idea why Linux tries to work with MTU > 1500 bytes when not
> configured explicitly to do so (may I have missed more
> options/checkings) ? Hope not to be cheated by Ethereal ...

I suppose you refer here to what GSO is doing though the explanation
is so fuzzy that I lost track of it in the middle. ...You needs
ethtool to configure it.

-- 
 i.
---696208474-277559276-1234195741=:31742--
