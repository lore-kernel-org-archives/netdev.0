From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] prism54: wpa support for fullmac cards
Date: Wed, 04 Oct 2006 07:40:11 -0400
Message-ID: <1159962011.2708.19.camel@localhost.localdomain>
References: <200610031457.33215.chunkeey@web.de>
	 <20061004123849.060a1842@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: chunkeey@web.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47517 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030825AbWJDLiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 07:38:14 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061004123849.060a1842@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 12:38 +0200, Jiri Benc wrote:
> On Tue, 3 Oct 2006 14:57:33 +0200, chunkeey@web.de wrote:
> > This patch (prism54-en-wpa3.patch) brings WPA/WPA2(RSN) with 
> > TKIP-Cipher to everyone with a FULLMAC Prism GT/Indigo/Duette card.
> > I removed all the parts(e.g.: Hostapd Support) which are not relevant for 
> > wpa_supplicant (client/managed mode).
> 
> Are you proposing a patch that removes AP support from the driver or did
> I understand it wrong?

I believe it adds the support back in, just using standard WE ioctls
like ENCODEEXT and AUTH rather than the custom HostAP ones...  which
brings up the question whether the hostapd driver for wext (is there
such a thing?) works well enough.

Dan

> Thanks,
> 
>  Jiri
> 

