From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 21:05:52 +0200
Message-ID: <20060926190552.GA15039@electric-eye.fr.zoreil.com>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <1159289374.2782.39.camel@ux156> <20060926174915.GA12512@electric-eye.fr.zoreil.com> <200609262010.50420.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:20941 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932474AbWIZTJ7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 15:09:59 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200609262010.50420.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb@bu3sch.de> :
[...]
> > 3 - The data in the eeprom contains u16 and it has a known endianness.
> >     It can be annotated as such (__be16 eeprom[]). I do not know how to
> >     do the same with an u8 [].
> 
> No. The eeprom is mostly not be16. The eeprom is mostly little
> endian, except the mac address and some wireless specific bits
> I forgot.

Sorry, s/__be16/__le16/

-- 
Ueimor
