From: "Luca Tettamanti" <kronos.it@gmail.com>
Subject: Re: [atl1-devel] APIC error on 32-bit kernel
Date: Wed, 28 Mar 2007 01:11:13 +0200
Message-ID: <68676e00703271611k4082885fqe0768fdb05a0b65d@mail.gmail.com>
References: <20070323200817.1f3e39b9@osprey.hogchain.net>
	 <m14po6xvtf.fsf@ebiederm.dsl.xmission.com>
	 <20070327174925.5cefb091@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: "Jay Cliburn" <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:53880 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933354AbXC0XLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 19:11:14 -0400
Received: by wr-out-0506.google.com with SMTP id 76so2155414wra
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 16:11:13 -0700 (PDT)
In-Reply-To: <20070327174925.5cefb091@osprey.hogchain.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/28/07, Jay Cliburn <jacliburn@bellsouth.net> wrote:
> On Tue, 27 Mar 2007 14:42:20 -0600
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
> Thanks for replying, Eric.  I've added atl1-devel to the cc list.
>
> > Do you have msi's working in 2.6.21-rc4 in the x86_64 kernel?
>
> I can't personally verify it anymore because I removed x86_64 to
> duplicate the MSI problem on i386, but the driver was working fine under
> x86_64 in earlier versions of 2.6.21-rcX.  The first hint of a problem
> was a report on March 12 by a user running a 32-bit 2.6.19 Fedora 6
> kernel who encountered a kernel panic on network startup.
>
> > > We also do not see this problem on Intel-based motherboards, with
> > > either 32- or 64-bit kernels.
> >
> > Can you confirm MSI is enabled in those kernels as well?
>
> Absolutely, yes.  MSI is enabled and working for me on a 64-bit
> kernel on an Intel-based motherboard, and Luca Tettamanti reports no
> problems running a 32-bit kernel on a similar motherboard.  (Luca wrote
> the MSI patch for the atl1 driver.)

Well, I've a P5B-E, with Intel chipset (and Intel usually gets MSI right).
Can you run the linux firmware test
(http://www.linuxfirmwarekit.org/)? FADT test may shed some light on
the issue.

Luca
