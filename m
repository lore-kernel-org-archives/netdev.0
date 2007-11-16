From: Kevin Winchester <kjwinchester@gmail.com>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Thu, 15 Nov 2007 20:28:29 -0400
Message-ID: <200711152028.29734.kjwinchester@gmail.com>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org> <20071115100209.GB2513@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934269AbXKPA2q@vger.kernel.org>
In-Reply-To: <20071115100209.GB2513@shadowen.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On November 15, 2007 06:02:09 am Andy Whitcroft wrote:
> When testing some of the later 2.6.24-rc2-mm1+hotfix combinations on three
> of our test systems one job from each batch (1/4) failed.  In each case the
> machine appears to have booted normally all the way to a login: prompt.
> However in the failed boots the networking though apparently initialised
> completely and correctly (as far as I can tell from the console output), is
> reported as not responding to ssh connections.  The network interface seems
> to have been initialised on the right port, and the ssh daemons started.
>
> Two of the machines are powerpc boxes, the other an older x86_64.
> One machine is 4/4 in testing, just one.  Most of the other machines are
> still not able to compile this stack so do not contribute to our knowledge.
>
> Any ideas?
>

I see this as well - the computer boots fine but no network.  The only clues 
in the dmesg are:

[  294.097876] warning: process `dhclient' gets w/ old libcap
[  294.097893] warning: process `dhclient' sets w/ old libcap

So I'll try backing up the patch series to before:

add-64-bit-capability-support-to-the-kernel.patch

or so, and see if that's the problem.  If anyone has any other ideas, let me 
know.

-- 
Kevin Winchester
