From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Wed, 11 Feb 2009 16:55:46 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0902111641280.13501@bizon.gios.gov.pl>
References: <BAY103-DAV55D390C73C4EC5373A371B2BA0@phx.gbl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-1421884678-1234367747=:13501"
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:57926 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbZBKQQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 11:16:19 -0500
In-Reply-To: <BAY103-DAV55D390C73C4EC5373A371B2BA0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1421884678-1234367747=:13501
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT



On Wed, 11 Feb 2009, Marco Berizzi wrote:

> Hi Folks,
>
> I'm getting this error on 2.6.28.4 when I run tcpdump on
> the interface where ipsec packets are enc/decrypted.
>
> TIA
>
>> Feb 11 10:53:55 Pleiadi kernel: ------------[ cut here ]------------
>> Feb 11 10:53:55 Pleiadi kernel: WARNING: at net/core/skbuff.c:154 skb_truesize_bug+0x2e/0x33()
>> Feb 11 10:53:55 Pleiadi kernel: SKB BUG: Invalid truesize (268) len=134, sizeof(sk_buff)=172
<CUT>

This annoying problem is quite old (appeared in 2.6.25) and already known:
  http://bugzilla.kernel.org/show_bug.cgi?id=10996

Sadly, no one is interested in fixing it. :(

Best regards,

 				Krzysztof Olêdzki
---1144830174-1421884678-1234367747=:13501--
