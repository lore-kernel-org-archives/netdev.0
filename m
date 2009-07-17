From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 1/2 v4] fs_enet/mii-fec.c: fix MII speed calculation
Date: Fri, 17 Jul 2009 14:24:33 +0200
Message-ID: <20090717122433.6E7D0832E416@gemini.denx.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de> <1247780546-4426-1-git-send-email-wd@denx.de> <fa686aa40907161544je92317dy7abea6819746847@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54729 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934419AbZGQMYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 08:24:38 -0400
In-reply-to: <fa686aa40907161544je92317dy7abea6819746847@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

In message <fa686aa40907161544je92317dy7abea6819746847@mail.gmail.com> you wrote:
>
> I assume this is tested.  I have not tested this on my board, and I've

It was tested, but as it turns out not quite well :-(

> got one question below, but otherwise I think I can say....
...
> The calculation has changed here for non mpc5121 users.  Shouldn't the
> "clock = ppc_proc_freq;" line above be "clock = ppc_proc_freq / 2;"?
> Or was this also a bug in the original driver?

You are right. That's a bug in the new code. Fixed in next version of
the patch.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Swap read error.  You lose your mind.
