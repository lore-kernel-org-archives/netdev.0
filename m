From: Peter Moody <pmoody@google.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Fri, 01 Aug 2014 10:22:01 -0700
Message-ID: <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-security-module@vger.kernel.org, brandon.carpenter@pnnl.gov,
	casey@schaufler-ca.com, netdev@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <87y4v876bs.fsf@synack.fr> (Samir Bellabes's message of "Fri\, 01
	Aug 2014 14\:16\:55 +0200")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Samir,

>>  * Is there already an existing mechanism to do this?
>
> Hi Peter,
> I have built a such subsystem, for years now.
> Please, you can access latest public patchset here :
>
> https://lkml.org/lkml/2011/5/5/132

Interesting, thanks! I hadn't know about snet.

The patches don't apply cleanly, and while the merge wasn't difficult,
it looks like the code has gotten out of sync with mainline and doesn't
build (at least when applied to security-next). Did anything ever happen
with snet?

>From looking at the code, it looks kind of like a 'little-snitch' for
linux, is that right? A process tries to open a socket/etc and snet
requests that the user accept/reject the connection, and presumably
while the user is being queried one could dig through /proc to find the
exe/cmdline of the process making the request.

One thing that Hone does which snet doesn't seem to do (apologies if
this is incorrect but I can't test) is that it provides a full process
tree for a given pid back to init. When doing an investigation into a
system compromise, knowing what started the process making the
suspicious connection(s) (and what started *that* process) is often just
as important as knowing that there's a compromise to begin with.

Cheers,

> monitoring events is possible with snet.
>
> thanks,
>
> (resending, first mail didn't hit lists)
