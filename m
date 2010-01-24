From: Wolfgang Denk <wd@denx.de>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to fs_enet driver
Date: Sun, 24 Jan 2010 17:41:17 +0100
Message-ID: <20100124164117.DCB483F6C0@gemini.denx.de>
References: <1264039999-25731-1-git-send-email-agust@denx.de> <20100121.012235.161201297.davem@davemloft.net> <4B5871F2.9090005@grandegger.com> <201001231023.14372.arnd@arndb.de> <4B5C5BDF.6020001@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>, dzu@denx.de,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, agust@denx.de,
	kosmo@semihalf.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:57082 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656Ab0AXQlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 11:41:22 -0500
In-reply-to: <4B5C5BDF.6020001@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Wolfgang & Arnd,

In message <4B5C5BDF.6020001@grandegger.com> you wrote:
>
> Arnd Bergmann wrote:
...
> > Is there any chance of building a kernel that runs on both mpc8xx and
> > mpc5121? AFAIK, the 5121 is built on a 6xx core which is fundamentally
> > incompatible with 8xx due to different memory management etc.

It is my understanding as well that you cannot have a single image
that boots both on 8xx and on 6xx cores. The focus was more on things
like supporting MPC5200 and MPC512x with the same image.

> > Since this makes it all a compile-time decision, it should be solvable
> > with a very small number of carefully placed #ifdef in the header files
> > an no runtime detection at all.
> > 
> > Obviously this approach would not work for drivers that want to be portable
> > across different register layouts on otherwise compatible platforms.
> 
> You are probably right and your proposal would likely result in more
> transparent (less ugly) code. There has been some discussion about
> unifying FEC drivers when the patches (with the same subject) have been
> submitted for the first time in May last year, but it was not about 512x
> and 8xx, IIRC.

You can re-read this discussion here:

http://patchwork.ozlabs.org/patch/26927/

ee especiall Grant's note of 2009-05-21 15:36:11: "If it looks too
ugly, then just fork the driver."

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Immortality consists largely of boredom.
	-- Zefrem Cochrane, "Metamorphosis", stardate 3219.8
