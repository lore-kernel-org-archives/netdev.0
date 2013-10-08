From: Andi Kleen <andi@firstfloor.org>
Subject: Re: bug in passing file descriptors
Date: Tue, 8 Oct 2013 18:41:08 +0200
Message-ID: <20131008164108.GO6882@two.firstfloor.org>
References: <525308C4.1030007@nec-labs.com>
 <20131007.154226.533738557474978526.davem@davemloft.net>
 <5253199B.3000109@nec-labs.com>
 <20131007.173237.1669132001431607341.davem@davemloft.net>
 <87li24zo6x.fsf@tassilo.jf.intel.com>
 <52541769.1000306@nec-labs.com>
 <CALCETrVoUrcuzEx_TURoGE8_MJtZLOz-UDz6m69Vo6MCWG0zjg@mail.gmail.com>
 <52543065.7000209@nec-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Steve Rago <sar@nec-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:40242 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab3JHQlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 12:41:11 -0400
Content-Disposition: inline
In-Reply-To: <52543065.7000209@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just want the semantics to be consistent.  If you want Linux to
> always require applications that call recvmsg to provide a buffer
> size of CMSG_SPACE bytes long to retrieve control information, then
> fail the system call when the buffer is smaller.  But if you do
> this, you risk breaking applications that work with FreeBSD, Mac OS
> X, Solaris, and probably a few others.

The primary concern is to be binary compatible with Linux.

But not being compatible between 32bit and 64bit Linux processes on the same
host would seem like a serious problem to me.

> Regardless, copying 20 bytes and telling me you copied 24 is misleading and wrong.

The question is could it break existing Linux applications to change it?
And would it help with the 32/64bit compatibility?

If not some other way to fix the compat layer would need to be found.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
