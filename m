From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 31 Dec 2004 12:32:52 -0500
Message-ID: <1104514372.1047.326.camel@jzny.localdomain>
References: <20041229000928.GH32419@postel.suug.ch>
	 <1104282811.1090.314.camel@jzny.localdomain>
	 <20041229124842.GI32419@postel.suug.ch>
	 <1104330054.1089.329.camel@jzny.localdomain>
	 <20041229150140.GJ32419@postel.suug.ch>
	 <1104335620.1025.22.camel@jzny.localdomain>
	 <20041230174313.GB32419@postel.suug.ch>
	 <1104469111.1049.219.camel@jzny.localdomain>
	 <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1104511494.1048.303.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-31 at 11:44, jamal wrote:

> > with the following matches:

One thing i just remembered: You need to know the length of the matches
and their data in order to store them. This is why i was earlier
preaching putting them in TLVs. Some things dont need the datalen
like u32 - however i suspect most will.

So either need a length somewhere in the header or use TLVs for the
ematches in which you can make T=kind - still have 32 bit inside body
but reserve bits not used for flags for future use. Thoughts?.

BTW, for deleting - should not allow deleting one of N matches. Deletion
should be at selector level. Replace can be used to pretend a single
match was deleted.

cheers,
jamal
