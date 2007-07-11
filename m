From: "Jonathan Larsen" <agentc0re@gmail.com>
Subject: Re: Fwd: r8169 driver supporting the 8167 dev ID
Date: Tue, 10 Jul 2007 18:24:27 -0600
Message-ID: <71421f560707101724x42fb6c8ye82bd08a9c7bca5@mail.gmail.com>
References: <71421f560707091922y60dec801w836e1e4e88c36de2@mail.gmail.com>
	 <71421f560707091923y64565c84wecb1229c219642c4@mail.gmail.com>
	 <20070710212513.GB3436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:6059 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbXGKAY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:24:27 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1398263wxd
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 17:24:27 -0700 (PDT)
In-Reply-To: <20070710212513.GB3436@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The patchkit from 2.6.18 to (almost) current contains 47 patches.
> git is a wonderful tool for endless nights of S&M backporting but
> I'd appreciate to understand why you can not use a more recent kernel
> before engaging.
Not a problem, sorry i didn't mention it before.  i am using
smoothwall 3. it is using kernel 2.6.16.52.

i will also take a look at how to patch it currently using git.  never
used git before so i'll download it and compile it in on the dev box.
once i get it working, would running
> git format-patch v2.6.18..v2.6.23-rc1 -- drivers/net/r8169.c
update it so that it would compile a backwards port for me?



On 7/10/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Jonathan Larsen <agentc0re@gmail.com> :
> > I've been looking for the r8169 driver that is for the 2.6.x kernel
> > and also supports the device id 8167, 10ec.  chipset is the 8110sc.
> > im sure someone is familiar with this.
>
> It is not the most used chipset in the 816x family but there are
> some known users, yes.
>
> > i noticed on the most latest kernel that such a driver exists.  i
> > downloaded a gentoo live cd and found out.  im trying to compile a
> > driver for a  2.6.16.52 kernel, it's for smoothwall.
> > i was hoping someone could help me out in getting the source so i
> > could compile it under the 2.6.16.52 kernel and have it work with my
> > 8110sc chipset nic's.
>
> The patchkit from 2.6.18 to (almost) current contains 47 patches.
> git is a wonderful tool for endless nights of S&M backporting but
> I'd appreciate to understand why you can not use a more recent kernel
> before engaging.
>
> > hope i've included enough info and description in what i am trying to
> > accomplish.  i just hope it's possible.  thank you! :)
>
> git format-patch v2.6.18..v2.6.23-rc1 -- drivers/net/r8169.c
> gives a good summary of the changes in the r8169 driver.
>
> One starts from a 2.6.16.something base and cycle through
> {apply/ignore}/compile/fix {reject/api change} for each
> patch until the r8169 driver reaches a decent state.
>
> It is not difficult but it takes time.
>
> --
> Ueimor
>
