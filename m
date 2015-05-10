From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2] ARM: net: add JIT support for loads from struct
 seccomp_data.
Date: Sun, 10 May 2015 20:40:28 +0100
Message-ID: <20150510194028.GA2067@n2100.arm.linux.org.uk>
References: <1431003613-16554-1-git-send-email-nschichan@freebox.fr>
 <20150509.222858.26253293963482182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nschichan@freebox.fr, dborkman@redhat.com, ast@plumgrid.com,
	mgherzan@gmail.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:35509 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbEJTkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:40:47 -0400
Content-Disposition: inline
In-Reply-To: <20150509.222858.26253293963482182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 09, 2015 at 10:28:58PM -0400, David Miller wrote:
> From: Nicolas Schichan <nschichan@freebox.fr>
> Date: Thu,  7 May 2015 15:00:13 +0200
> 
> > Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> > ---
> > 
> > This patch was first sent as part of a serie modifying the core
> > seccomp code to allow the use of the classic BPF JIT. As the core
> > changes have been submitted to netdev by Daniel Borkmann, it is now
> > time to re-submit this patch separately.
> > 
> > While not physically dependent of the core seccomp changes they are
> > needed for the code added in this patch to be triggered.
> 
> Where would you like this to be applied, my tree?
> 
> This is an ongoing situation, where people have traditionally not
> consistently wanted bpf JIT patches to go into the networking tree.
> 
> So I beg everyone posting such things to netdev to be _clear_
> and _explicit_ about whether you expect me to integrate the patch
> or not.

I think you have taken previous ARM net JIT patches, so I think it
makes sense if you continue to do so.  I'm not knowledgable of the
JIT interface myself, all I can say about many of these patches is
that they look okay to me on a superficial basis.

I suspect you're doing more or less the same, but from a slightly
different perspective (presumably through not knowing ARM assembly.)

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
