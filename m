From: Brad House <brad@mcve.com>
Subject: Re: r8169 and tg3
Date: Mon, 17 Nov 2003 23:51:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB9A55C.5090901@mcve.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brad House <brad_mssw@gentoo.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FB9A277.70309@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Commenting below:
> 
> So, what needs to happen is somebody needs to look at the sis190 changes 
> that went in, and apply those same fixes to r8169.

Ok, cool. Didn't realize that, if you have a couple of references to
those discussions or patches, that would be awesome (so I don't have
to try to dig them up), otherwise, I'll research it some.
I was also going to look into merging the big endian patches I saw
posted earlier this month.

> 1) If you have problems with the tg3 driver, we need to get those bug 
> reports and fix them.  bcm5700 is not going to be merged into the 
> kernel.  Further, there was at least one serious x86-64 issue that was 
> fixed in tg3, and we need to make sure users are testing that driver, 
> not a non-standard driver with bugs of its own.

Ok, sounds like a plan. I'll get some testing on the latest tg3 driver
then, have those been merged into 2.6.0-test9-bk21, or is there another
patch I need to apply to my local tree (and in turn will be applied
to Gentoo's tree)?

> 
> 2) Please CC me on all net driver patches, since I am the dude that 
> actually puts those patches into the kernel.

Cool, no problem.
I just took over the amd64 port for Gentoo a couple months back,
so I'm having to get into some stuff I haven't had to do before.
But I'm starting to learn some of the kernel internals/driver
infrastructure, so hopefully I'll be of some actual help in the
near future, assuming my actual job doesn't get in the way ;)

-Brad
