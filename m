From: Danny <dannydaemonic@gmail.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Thu, 14 Oct 2004 15:04:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9625752b04101415043a078b93@mail.gmail.com>
References: <9625752b041012230068619e68@mail.gmail.com>
	 <9625752b041013091772e26739@mail.gmail.com>
	 <9625752b04101309182a96fbd2@mail.gmail.com>
	 <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
	 <20041013181840.GA30852@electric-eye.fr.zoreil.com>
	 <9625752b04101313417be4cf90@mail.gmail.com>
	 <20041013205433.GC30761@electric-eye.fr.zoreil.com>
	 <9625752b04101314595f72f84a@mail.gmail.com>
Reply-To: Danny <dannydaemonic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <9625752b04101314595f72f84a@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I wasn't able to get the kernel to compile with just the reiser4
patches from the broken-out dir on the ftp.  The patching itself
seemed to go well though.  I tried to apply the patches in the order
they were listed in "series" but some had to go out of order anyway,
such as reiser4-only.patch had to go first.

However I was able to verify it's not a problem with the r8169 driver.
 I copied over the r8169 driver to a fresh linux-2.6.8.1-mm4 and was
able to compile and run fine with the latest r8169 driver from the
linux-2.6.9-rc4-mm1 release.  I also tested it in reverse, bringing
over r8169.c to a fresh linux-2.6.9-rc4-mm1 and it still gave me the
oops.

I'm not sure where this leaves me now.  Perhaps I should repost my
oops and my proc info in the lkml with a different subject to draw the
attention of others, since I now know this subject to be entirely
missleading.
