From: Danny <dannydaemonic@gmail.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Wed, 13 Oct 2004 13:28:55 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <9625752b04101313283f035423@mail.gmail.com>
References: <9625752b041012230068619e68@mail.gmail.com>
	 <9625752b041013091772e26739@mail.gmail.com>
	 <9625752b04101309182a96fbd2@mail.gmail.com>
	 <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
Reply-To: Danny <dannydaemonic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269818AbUJMU30@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <200410131129.05657.jdmason@us.ltcfwd.linux.ibm.com>
List-Id: netdev.vger.kernel.org

On Wed, 13 Oct 2004 11:29:05 -0500, Jon Mason wrote:
> Can you confirm that you are running r8169 driver with NAPI and TSO turned on,
> along with Preemptable Kernel?  Also, I didn't see anything in the Oops
> specific to the r8169 driver, do you have another adapter available to run
> the same test on?  Finally, what is your setup (arch, # of cpus, etc)?

I am using the r8169 driver with NAPI and preemptable kernel.  I don't
remember or see any option for offloading but it sounds like something
I'd turn on.  Let me know what I should look for in my config, or
check here:
http://members.cox.net/valenzdu/.config

I no longer have a 2nd nic adapter, but I did first notice the problem
when I installed this one.  However, if I don't load that module I'm
not able to duplicate the problem by running named on the other
interface.  Running named triggers it 100% of the time on the r8169
based nic.

The arch is x86 (athlon) with just 1 cpu.  Since I'm not sure what's
wrong here I'm not sure what's relevant.  Here is more info about my
setup:
http://members.cox.net/valenzdu/proc-cpuinfo
http://members.cox.net/valenzdu/proc-iomem
http://members.cox.net/valenzdu/proc-ioports
http://members.cox.net/valenzdu/proc-modules
http://members.cox.net/valenzdu/proc-version
http://members.cox.net/valenzdu/stdout-lspci
http://members.cox.net/valenzdu/stdout-ver_linux
