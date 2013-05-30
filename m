From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Thu, 30 May 2013 15:38:46 +0200
Message-ID: <87fvx4mvtl.fsf@nemi.mork.no>
References: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57370 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755894Ab3E3NjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 09:39:06 -0400
In-Reply-To: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>
	(Narendra K.'s message of "Thu, 30 May 2013 18:55:47 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<Narendra_K@Dell.com> writes:

> From: Narendra K <narendra_k@dell.com>
>
> 'dev_id' sysfs attribute is initialized to zero by default.
> It is also zero based. This creates ambiguity in differentiating
> whether the driver set it to zero or it is the default value.
> Initialize 'dev_id' to -1 to make the scenario unambiguous.

I understand your concern, but I don't think you can do this.  It
changes the userspace API, and has some very visible side effects.

Please take a look at net/ipv6/addrconf.c


Bj=C3=B8rn
