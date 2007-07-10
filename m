From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: r8169 driver supporting the 8167 dev ID
Date: Tue, 10 Jul 2007 23:25:13 +0200
Message-ID: <20070710212513.GB3436@electric-eye.fr.zoreil.com>
References: <71421f560707091922y60dec801w836e1e4e88c36de2@mail.gmail.com> <71421f560707091923y64565c84wecb1229c219642c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Larsen <agentc0re@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54703 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852AbXGJV2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 17:28:52 -0400
Content-Disposition: inline
In-Reply-To: <71421f560707091923y64565c84wecb1229c219642c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jonathan Larsen <agentc0re@gmail.com> :
> I've been looking for the r8169 driver that is for the 2.6.x kernel
> and also supports the device id 8167, 10ec.  chipset is the 8110sc.
> im sure someone is familiar with this.

It is not the most used chipset in the 816x family but there are
some known users, yes.

> i noticed on the most latest kernel that such a driver exists.  i
> downloaded a gentoo live cd and found out.  im trying to compile a
> driver for a  2.6.16.52 kernel, it's for smoothwall.
> i was hoping someone could help me out in getting the source so i
> could compile it under the 2.6.16.52 kernel and have it work with my
> 8110sc chipset nic's.

The patchkit from 2.6.18 to (almost) current contains 47 patches.
git is a wonderful tool for endless nights of S&M backporting but
I'd appreciate to understand why you can not use a more recent kernel
before engaging.

> hope i've included enough info and description in what i am trying to
> accomplish.  i just hope it's possible.  thank you! :)

git format-patch v2.6.18..v2.6.23-rc1 -- drivers/net/r8169.c
gives a good summary of the changes in the r8169 driver.

One starts from a 2.6.16.something base and cycle through
{apply/ignore}/compile/fix {reject/api change} for each
patch until the r8169 driver reaches a decent state.

It is not difficult but it takes time.

-- 
Ueimor
