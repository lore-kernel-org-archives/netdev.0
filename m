From: Danny <dannydaemonic@gmail.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Wed, 13 Oct 2004 13:44:02 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <9625752b04101313445a67923@mail.gmail.com>
References: <9625752b041012230068619e68@mail.gmail.com>
	 <9625752b041013091772e26739@mail.gmail.com>
	 <9625752b04101309182a96fbd2@mail.gmail.com>
	 <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
	 <20041013181840.GA30852@electric-eye.fr.zoreil.com>
Reply-To: Danny <dannydaemonic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269837AbUJMUoO@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20041013181840.GA30852@electric-eye.fr.zoreil.com>
List-Id: netdev.vger.kernel.org

On Wed, 13 Oct 2004 20:18:40 +0200, Francois Romieu wrote:
> Danny, can your drop the r8169 driver from 2.6.9-rc4-mm1 into vanilla
> 2.6.9-rc4 and confirm that it works (preempt should not matter) ?

I see how the timing on the installation of the r8169 could have just
been bad.  Since preempt shouldn't matter, I'm going to test that
and acpi etc first (because it's easier to test heh).

See, well, I'm going to need reiser4 for the vanilla.  I found patches here:
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.9-rc4/2.6.9-rc4-mm1/broken-out/

But can someone point out which patches I will need?  Do I only need
reiser4-only.patch or is it safer for my fs if I have all the other
reiser4 patches?
