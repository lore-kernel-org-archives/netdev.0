From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: IPSec: IPv6 random failures
Date: Fri, 23 May 2003 10:42:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFD45FE8D2.BE223435-ON86256D2F.004DFD33-86256D2F.005647E2@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Can someone review and stress test out this patch for me?

I had been testing on 2.5.69 so I used the 2.5.69-bk16 patch to test out
the fix.  I was getting a hang at random times during my tests.  I didn't
know if it was the result of this fix or something else in the bk16 patch.
So I got the bk15 patch (which doesn't have your fix) and tested on that
and again received a hang at random times during my tests.  Although both
levels didn't consistently fail on the same test case, though both seemed
to hang the system right after flushing the SPs and SAs.  So while it
doesn't appear that your fix is causing the hang, something is wrong.  I'll
try and do some debugging and see if I can find the problem.

Thanks,
Tom

toml@us.ibm.com
