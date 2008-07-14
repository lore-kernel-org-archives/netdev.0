From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
	Problem)
Date: Mon, 14 Jul 2008 18:21:00 +0200
Message-ID: <1216052460.23392.14.camel@localhost>
References: <4861800B.90703@nscus.com>
	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>
	 <48640535.2050000@nscus.com>
	 <20080626215918.GC2555@electric-eye.fr.zoreil.com>
	 <1215435236.11909.121.camel@localhost>  <487232F4.6000206@dell.com>
	 <1215783324.11909.185.camel@localhost>  <48777BC3.6090108@dell.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <48777BC3.6090108@dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-07-11 at 10:26 -0500, Mario Limonciello wrote:
> Kasper:
> 
> http://marc.info/?l=linux-netdev&m=121498012600793&w=2

I just tested it. It fails.

after a few unloads/loads the lspci -x output is garbled again. the
funny thing is (i have a dual nic board) its random which one that
breaks..

Francois, i tested your patch,
http://userweb.kernel.org/~romieu/r8169/2.6.26-rc9/20080710-r8169-test.patch against .26 and it WORKS. with all the other tests i've done, ~5 unloads/loads is more than enough to trigger it, i just did 50 on your patch, and it functions.

Now i can have both msi and apic on.. Thanks alot.

Do you have plans to get this merged?

> 
> Regards
> 
> Kasper Sandberg wrote:
> > On Mon, 2008-07-07 at 10:15 -0500, Mario Limonciello wrote:
> >   
> > Sorry, i am not subscribed to netdev or pci list, could you post here
> > aswell?
> >
> >   
> >
> >   
> 
