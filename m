From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: TAHI Conformance Test
Date: Mon, 07 Feb 2005 19:41:36 +0900 (JST)
Message-ID: <20050207.194136.130656563.yoshfuji@linux-ipv6.org>
References: <20050207102553.28a46fcd.didier@barvaux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	usagi-users@linux-ipv6.org
To: didier@barvaux.org
In-Reply-To: <20050207102553.28a46fcd.didier@barvaux.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please do not multipost...

In article <20050207102553.28a46fcd.didier@barvaux.org> (at Mon, 7 Feb 2005 10:25:53 +0100), Didier Barvaux <didier@barvaux.org> says:

> I'm searching for information about the current status of IPv6 in the Linux 2.6/2.4 vanilla kernels. Unfortunately, I have not found up-to-date data.
> 
> I have found Peter Bieringer's 'IPv6 & Linux' page [1] and some quite old TAHI Conformance Test's results on kernel 2.6.1 [2] from the USAGI project. As you can see, information I have found are quite outdated.
> 
> So, have someone more up-to-date data ?

Well, we haven't tested vanilla linux-2.4.x recently.
However, linux-2.6.11-rc2 w/ usagi-tools (userspace daemon etc.),
acting as host and/or router, passed IPv6 Ready Logo [1]
Phase 1 Self-Test, which is similar to CT.
(Note: usagi-linux24 and usagi-linux26 passed it, too.)

And, we are trying passing Phase 2 Self-Test as well.
My private tree already passed it, and patches will soon be available
(in linux-2.6.12 timeframe).

I think linux-2.6.11-rc2 w/ usagi-tools can pass TAHI CT;
we will test later.

We may try to backport changes to 2.4.x.

I hope this helps.  Thanks.

[1] http://www.ipv6ready.org

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
