From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 07 Apr 2008 08:39:49 -0700
Message-ID: <1207582789.21308.133.camel@localhost.localdomain>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <1207326576.21308.71.camel@localhost.localdomain>
	 <200804072256.IFJ17170.QFOJFHtLSOOVFM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	haradats@nttdata.co.jp, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:13318 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbYDGPjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 11:39:52 -0400
In-Reply-To: <200804072256.IFJ17170.QFOJFHtLSOOVFM@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-07 at 22:56 +0900, Tetsuo Handa wrote:
> Daniel Walker wrote:
> > From a reviews perspective what I would want is each set of changes,
> > file system, networking, arch, etc split into separate patches. For
> > example you have a number of patches just adding header files. You could
> > merge the header file with the hook additions. Then you have a natural
> > code split up which should be easier to review..
> Filesystem part to fsdevel, socket operation part to netdev. That's OK.
> But I wonder where to post the rest part.
> Since the patches for passing "struct vfsmount" to LSM has been rejected,
> TOMOYO has been unable to use LSM.
> Thus, I proposed this patch set as a non-LSM version, but it bothers me
> where to post this patch. If you know, please teach me where to post.

Not sure .. You might look through the MAINTAINERS file and see if
anyone maintains the sections of code your changing. Usually LKML and
Andrew are pretty good bets especially when your not sure who the
patches should go to.

Daniel

