From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Mon, 30 Nov 2015 22:07:43 +0100
Message-ID: <1448917663.3546.29.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
	 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
	 <1448906497.3546.16.camel@tiscali.nl> <565C95B7.7070001@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565C95B7.7070001@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On ma, 2015-11-30 at 19:30 +0100, Tilman Schmidt wrote:
> I wonder how that will behave if someone attaches two of the devices to
> different serial ports. Not likely, but not forbidden either.

I see.

Perhaps I should respin and a use a pointer to a struct platform_device
in struct ser_cardstate, use the two step approach of
platform_device_alloc() and friends, etc. Only slightly more
complicated.

How would attaching two devices work with GIGASET_MINORS hardcoded to 1?
Because I haven't yet stumbled on the mechanism with which ttyGS1 (and
up) would then be created.

(I do have a second M105's in a box somewhere, so I could check myself
what happens when a second USB device is added, for what that's worth.)

Thanks,


Paul Bolle
