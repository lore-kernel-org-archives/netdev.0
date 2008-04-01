From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [2.6 patch] forgotten bits of Sangoma drivers removal
Date: Mon, 31 Mar 2008 23:14:46 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0803312313210.21490@localhost.localdomain>
References: <20080330224901.GW28445@cs181133002.pp.htv.fi> <20080331.193329.195976331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:33463 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbYDADOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 23:14:53 -0400
In-Reply-To: <20080331.193329.195976331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Mar 2008, David Miller wrote:

> From: Adrian Bunk <bunk@kernel.org>
> Date: Mon, 31 Mar 2008 01:49:01 +0300
>
> > Robert P. J. Day spotted that my removal of the Sangoma drivers missed a
> > few bits.
> >
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
> I must have missed some context or another patch, but
> linux/if_wanpipe.h is still there, so I can't see why
> we can remove it from linux/Kbuild

AFAICT, nothing in the source tree includes that header file, so i'm
guessing that the patch should also include simply deleting it if it
has no further value.

rday
--

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
