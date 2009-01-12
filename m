From: Oliver Neukum <oliver@neukum.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 10:11:29 +0100
Message-ID: <200901121011.31947.oliver@neukum.org>
References: <200812221454.57794.oliver@neukum.org> <496B0605.70704@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, schwidefsky@de.ibm.com,
	strasse@de.ibm.com, Paul Hardwick <P.Hardwick@option.com>,
	ajb@spheresystems.co.uk, "Greg Kroah-Hartman" <greg@kroah.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:59879 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbZALJLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 04:11:04 -0500
In-Reply-To: <496B0605.70704@option.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Monday 12 January 2009 09:57:41 schrieb Denis Joseph Barrow:

> Oliver if you haven't given a detailed description of the patch you need to do so before the patch can be accepted
> especially a patch of this size.

I'll do an extended description.
 
> Can the patch be broken down into seperate patches 1 for each bug? have you used quilt and linux/scripts/checkpatch.pl
> before?

This patch solves just one bug, so I cannot split it up along
these lines. Basically you race against suspend and that required
a change in locking which in turn required that I touch most places
where locks are taken, so the patch is large.

	Regards
		Oliver
