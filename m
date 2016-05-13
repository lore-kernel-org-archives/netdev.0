From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH v2 0/2] wireless: Allow wiphy/hwsim management from user
 namespaces
Date: Fri, 13 May 2016 12:37:08 +0200
Message-ID: <1463135828.1443.6.camel@strongswan.org>
References: <1462811639-29906-1-git-send-email-martin@strongswan.org>
	 <1463045221.13313.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:58611 "EHLO
	mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbcEMKhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 06:37:12 -0400
In-Reply-To: <1463045221.13313.16.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi=C2=A0Johannes,

> So I think you should change the "wmediumd_portid" variable to live
> in=C2=A0struct hwsim_net and then allow HWSIM_CMD_REGISTER to be done
> inside the net namespace.
>=20
> With that, and making the other few wmediumd related operations
> namespace aware, we would be able to run wmediumd in any net
> namespace and have it manage all the radios created in that
> namespace.

Yes, that makes sense. I've a patch mostly ready, but it needs some
more testing before I can submit it. Hope to complete that today.

While testing I've hit a Netlink verification issue that I'll
separately submit a patch for.

Best regards
Martin
