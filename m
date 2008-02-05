From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 22:05:10 +0000
Message-ID: <20080205220510.09258826@core>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
	<20080205155558.GA23145@one.firstfloor.org>
	<c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com>
	<20080205200211.GA26150@one.firstfloor.org>
	<20080205203911.GA9891@2ka.mipt.ru>
	<20080205212017.5db50114@core>
	<20080205215216.GB24275@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:42885 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760745AbYBEWNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 17:13:08 -0500
In-Reply-To: <20080205215216.GB24275@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> SACK is actually a good idea for mobile devices, so preventing
> syncookies from not getting into account some options (btw, does it work
> with timestamps and PAWS?) is not a solution.

Syncookies only get used at the point where the alternative is failure.
No SACK beats a DoS situation most days
