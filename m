From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][GENETLINK] introduce command names
Date: Mon, 04 Dec 2006 08:09:02 -0500
Message-ID: <1165237742.3664.22.camel@localhost>
References: <1165061496.3564.11.camel@localhost>
	 <20061204092857.GO8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:33775 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936811AbWLDNJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:09:08 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1852138nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 05:09:07 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204092857.GO8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 10:28 +0100, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-12-02 07:11
> > [GENETLINK] introduce command names
> > 
> > Introduce optional command names.
> > While command names can be put in user space by the author of the
> > command, this alleviates things for the discovery process without
> > requiring any user space code written.
> > In a recent tutorial that i gave, the desire for this feature was
> > the highest.
> 
> I assume you're planning to export this to userspace at some point?

Right.

> What's the real advantage besides that when listing avaiable
> operations we can output names instead of numbers? 

Just makes the discovery more knowledgeable. 
Theres a hidden meaning in that i would like if possible to create
as much of user space as possible without the user having a single line
written. Heres how i output the discovered families at the moment
without the patch.

-----
hadi@lilsol:~/git-trees/iproute2/nov22/genl$ ./genl ctrl ls
Added Family  Name: nlctrl
        ID: 0x10  Version: 0x1  header size: 0  max attribs: 6 
        commands supported: 
                #1:  ID-0x3  flags-0x0 
                        Capabilities:  has policy; can doit; can dumpit

Added Family  Name: TASKSTATS
        ID: 0x11  Version: 0x1  header size: 0  max attribs: 4 
        commands supported: 
                #1:  ID-0x1  flags-0x0 
                        Capabilities:  has policy; can doit;

hadi@lilsol:~/git-trees/iproute2/nov22/genl$ 
-----------

It would be a lot more human friendly to put better readability in the
commands.

> Userspace should
> be aware of operation numbers when using it. I'm all for this if
> the direction is to move towards having some form of scriptable
> genetlink tool which can be used to communicate with simple genetlink
> families.
> 

That is the real agenda actually. To be honest i dont know how realistic
it would be. But one of the next things is to output the command
policies.

> I guess the desire was the highest because you sold it as such :-)

Theres some truth to that ;-> But i didnt start it;->, after two people
asking why they couldnt tell the command name, it connected to me i also
need it for this other reason. 

cheers,
jamal

