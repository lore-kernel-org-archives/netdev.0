From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to fs_enet driver
Date: Wed, 27 Jan 2010 03:06:21 +0100
Message-ID: <201001270306.22089.arnd@arndb.de>
References: <1264039999-25731-1-git-send-email-agust@denx.de> <4B5C5BDF.6020001@grandegger.com> <20100124164117.DCB483F6C0@gemini.denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	dzu@denx.de, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	agust@denx.de, kosmo@semihalf.com,
	Grant Likely <grant.likely@secretlab.ca>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:61680 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab0A0CGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 21:06:36 -0500
In-Reply-To: <20100124164117.DCB483F6C0@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 24 January 2010, Wolfgang Denk wrote:
> In message <4B5C5BDF.6020001@grandegger.com> you wrote:
> > 
> > You are probably right and your proposal would likely result in more
> > transparent (less ugly) code. There has been some discussion about
> > unifying FEC drivers when the patches (with the same subject) have been
> > submitted for the first time in May last year, but it was not about 512x
> > and 8xx, IIRC.
> 
> You can re-read this discussion here:
> 
> http://patchwork.ozlabs.org/patch/26927/
> 
> ee especiall Grant's note of 2009-05-21 15:36:11: "If it looks too
> ugly, then just fork the driver."

Ok. I fully agree with what Grant said in that thread, especially the
way the files could be split. Forking the entire driver would work
as an easy way to get it running at first, and we still have the option
of reorganizing the duplicate parts later in a saner way if that's seen
as helpful. I'd assume that at least some parts of it could become a
lib_fs_enet module that can be shared by all of them.

	Arnd
