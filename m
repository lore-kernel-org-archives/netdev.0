From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 10/14 v2] nes: eeprom and phy routines
Date: Wed, 31 Oct 2007 13:26:29 -0700
Message-ID: <ada1wbbghe2.fsf@cisco.com>
References: <200710192021.l9JKLGFU021817@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ewg@lists.openfabrics.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:22699 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354AbXJaU0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 16:26:43 -0400
In-Reply-To: <200710192021.l9JKLGFU021817@neteffect.com> (ggrundstrom@neteffect.com's message of "Fri, 19 Oct 2007 15:21:16 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +	/* TODO: deal with EEPROM endian issues */

This is pretty scary.  Is the driver broken on big-endian systems now?

 > +/*
 > +"Everything you wanted to know about CRC algorithms, but were afraid to ask
 > + for fear that errors in your understanding might be detected." Version  : 3.

etc etc... can all this be replaced with what's in lib/crc32.c?  (I
hope so)

 - R.
