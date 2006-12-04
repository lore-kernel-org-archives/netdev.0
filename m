From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][GENETLINK] introduce command names
Date: Mon, 4 Dec 2006 17:34:51 +0100
Message-ID: <20061204163451.GS8693@postel.suug.ch>
References: <1165061496.3564.11.camel@localhost> <20061204092857.GO8693@postel.suug.ch> <1165237742.3664.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38103 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937102AbWLDQea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 11:34:30 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1165237742.3664.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-04 08:09
> Just makes the discovery more knowledgeable. 
> Theres a hidden meaning in that i would like if possible to create
> as much of user space as possible without the user having a single line
> written. Heres how i output the discovered families at the moment
> without the patch.
> 
> -----
> hadi@lilsol:~/git-trees/iproute2/nov22/genl$ ./genl ctrl ls
> Added Family  Name: nlctrl
>         ID: 0x10  Version: 0x1  header size: 0  max attribs: 6 
>         commands supported: 
>                 #1:  ID-0x3  flags-0x0 
>                         Capabilities:  has policy; can doit; can dumpit
> 
> Added Family  Name: TASKSTATS
>         ID: 0x11  Version: 0x1  header size: 0  max attribs: 4 
>         commands supported: 
>                 #1:  ID-0x1  flags-0x0 
>                         Capabilities:  has policy; can doit;
> 
> hadi@lilsol:~/git-trees/iproute2/nov22/genl$ 
> -----------
> 
> It would be a lot more human friendly to put better readability in the
> commands.

I don't agree to waste so much text section just to fancy up some
userspace tool which is mainly a toy while developing. If you
really need it, do it in userspace like libnl.

> > Userspace should
> > be aware of operation numbers when using it. I'm all for this if
> > the direction is to move towards having some form of scriptable
> > genetlink tool which can be used to communicate with simple genetlink
> > families.
> > 
> 
> That is the real agenda actually. To be honest i dont know how realistic
> it would be. But one of the next things is to output the command
> policies.

Once we go that path we can reconsider a patch based on this which
includes the bits to dump the information to userspace. Until then
I don't see the point in this.
