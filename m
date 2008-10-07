From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Multicast: add mc_count to in_device and to
 inet6_dev
Date: Tue, 07 Oct 2008 15:36:43 -0700 (PDT)
Message-ID: <20081007.153643.247018258.davem@davemloft.net>
References: <b25312890809302357j6b75dd27uced2968046c10993@mail.gmail.com>
	<20081001.020854.146740849.davem@davemloft.net>
	<b25312890810012224h68a2444dob746eaf0ce80b111@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi
To: roszenrami@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53089
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754734AbYJGWhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:37:07 -0400
In-Reply-To: <b25312890810012224h68a2444dob746eaf0ce80b111@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <roszenrami@gmail.com>
Date: Thu, 2 Oct 2008 08:24:33 +0300

>   - When sending the patch, I was aware that the mc_count is currently
> not used (printed) in IPv6;
> I added it for the sake of symmetry with IPv4 and for future use.

Unused struct members take up space in every instance of that
datastructure, so we don't add things like this until we have
real uses.

> - Adding printing of mc_count in IPv6 is of course trivial; it was not
> added not because of laziness;  I know less about IPv6 user space
> tools (which read "/proc/net/igmp6") ; I was afraid that adding
> printing of this mc_count field in IPv6 might break parsing of IPv6
> user space tools (like netstat, etc).
> So maybe this addition should be left for somebody who knows more
> about IPv6 user space tools ?

Of course modifying the output of this procfs file will break
things.  This is yet another reason to not add the ipv6 side
mc_count until we actually come up with a real use.
