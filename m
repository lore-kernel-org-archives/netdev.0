From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Wed, 27 Sep 2006 09:55:22 +0200
Message-ID: <1159343722.2698.4.camel@ux156>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net>
	 <200609261804.37422.mb@bu3sch.de> <4519508A.4010004@garzik.org>
	 <200609261820.46308.mb@bu3sch.de>  <45195C92.4040503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45226 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932163AbWI0Hyj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 03:54:39 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45195C92.4040503@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-26 at 13:00 -0400, Jeff Garzik wrote:

> False.  It's already fixed endian.  It's just not the endian you like.

No, that's where you're wrong. It isn't fixed endian. It's CPU endian,
and the thing overlays a u8 array over CPU endian, hence it's not fixed.

johannes
