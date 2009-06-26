From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 0/4 for 2.6.31] NET: Revive fixed link support
Date: Fri, 26 Jun 2009 17:35:25 -0600
Message-ID: <fa686aa40906261635i2b7fb95bsb6b7357c1bc288f0@mail.gmail.com>
References: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:63019 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbZFZXfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 19:35:42 -0400
Received: by gxk26 with SMTP id 26so1462688gxk.13
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 16:35:45 -0700 (PDT)
In-Reply-To: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 4:29 PM, Anton
Vorontsov<avorontsov@ru.mvista.com> wrote:
> Hi all,
>
> The fixed link support is broken since The Big OF MDIO Rework,
> the rework simply removed most of the code that was needed for
> fixed links.
>
> Too bad I didn't notice this earlier, I saw a bunch of patches
> on the ml, but unfortunately I didn't look very close presuming
> that Grant knew what he was doing. :-) And obviously I didn't
> test linux-next on anything that requires a fixed link.

Apparently I didn't.  sorry.

> Anyway, here are four patches. The first one adds the fixed link
> support to a framework, otherwise we'd duplicate the code across
> the drivers (as we did previously), and I tried to keep drivers'
> changes minimal.

As I described in my previous email, I don't think this is a good
approach and I don't think it should be merged.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
