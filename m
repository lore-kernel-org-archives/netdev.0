From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Tue, 01 Dec 2015 11:05:22 +0100
Message-ID: <1448964322.3546.46.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
	 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
	 <1448906497.3546.16.camel@tiscali.nl> <565C95B7.7070001@imap.cc>
	 <1448917663.3546.29.camel@tiscali.nl> <565D68C8.5050901@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, isdn@linux-pingi.de,
	davem@davemloft.net, gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565D68C8.5050901@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On di, 2015-12-01 at 10:30 +0100, Tilman Schmidt wrote:
> Am 30.11.2015 um 22:07 schrieb Paul Bolle:
> > How would attaching two devices work with GIGASET_MINORS hardcoded
> > to 1?
> 
> Ah, it wouldn't. You'd have to recompile with a bigger GIGASET_MINORS.
> 
> (I wonder if that would actually work. Somehow I still think of
> GIGASET_MINORS as a configurable value, but it has never been anything
> but 1 in the entire in-tree history of the driver.)

That ends a prolonged session of head-scratching. I'll update the commit
explanation to reflect this conversation.

(Perhaps it's reasonable to wish to use two identical gigaset adapters
simultaneously. But given that the gigaset drivers have never supported
it, that hardly matters. So I might remove the proto-support for
multiple devices one day. That's far from urgent.)

Thanks for sticking around!


Paul Bolle
