From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Wed, 27 Jan 2010 09:13:18 +0100
Message-ID: <4B5FF59E.3090805@grandegger.com>
References: <1264039999-25731-1-git-send-email-agust@denx.de> <4B5C5BDF.6020001@grandegger.com> <20100124164117.DCB483F6C0@gemini.denx.de> <201001270306.22089.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Denk <wd@denx.de>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>, dzu@denx.de,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, agust@denx.de,
	kosmo@semihalf.com, Grant Likely <grant.likely@secretlab.ca>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:55289 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab0A0IOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 03:14:31 -0500
In-Reply-To: <201001270306.22089.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Sunday 24 January 2010, Wolfgang Denk wrote:
>> In message <4B5C5BDF.6020001@grandegger.com> you wrote:
>>> You are probably right and your proposal would likely result in more
>>> transparent (less ugly) code. There has been some discussion about
>>> unifying FEC drivers when the patches (with the same subject) have been
>>> submitted for the first time in May last year, but it was not about 512x
>>> and 8xx, IIRC.
>> You can re-read this discussion here:
>>
>> http://patchwork.ozlabs.org/patch/26927/
>>
>> ee especiall Grant's note of 2009-05-21 15:36:11: "If it looks too
>> ugly, then just fork the driver."
> 
> Ok. I fully agree with what Grant said in that thread, especially the
> way the files could be split. Forking the entire driver would work
> as an easy way to get it running at first, and we still have the option
> of reorganizing the duplicate parts later in a saner way if that's seen
> as helpful. I'd assume that at least some parts of it could become a
> lib_fs_enet module that can be shared by all of them.

Yes, I also vote for forking the driver allowing a clean implementation.
 I don't think it makes sense to share a driver with the 8xx for the
reasons you already mentioned. And the 8xx is a dying out arch anyway.

Wolfgang.
