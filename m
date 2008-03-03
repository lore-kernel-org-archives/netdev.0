From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Mon, 3 Mar 2008 22:41:57 +0200
Message-ID: <84144f020803031241l277aa3b8h2fe0714f5765cb49@mail.gmail.com>
References: <20080303093449.GA15091@wotan.suse.de>
	 <20080303093529.GB15091@wotan.suse.de>
	 <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
	 <20080303200355.GB8974@wotan.suse.de>
	 <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com>
	 <20080303201211.GE8974@wotan.suse.de>
	 <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com>
	 <20080303202411.GH8974@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Christoph Lameter" <clameter@sgi.com>, netdev@vger.kernel.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, "David Miller" <davem@davemloft.net>,
	"Eric Dumazet" <dada1@cosmosbay.com>
To: "Nick Piggin" <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:24620 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbYCCUl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:41:58 -0500
Received: by rv-out-0910.google.com with SMTP id k20so185680rvb.1
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 12:41:57 -0800 (PST)
In-Reply-To: <20080303202411.GH8974@wotan.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 3, 2008 at 10:24 PM, Nick Piggin <npiggin@suse.de> wrote:
>  > Then align the objects at cacheline boundaries by providing a value for
>  > the align parameter to kmem_cache_create().
>
>  max(num_possible_cpus() > 1 ? cache_line_size() : 0, mandatory_alignment)?
>
>  Then suppose we want a CONFIG_TINY option to eliminate it?

Hmm... Can't we just fix SLAB_HWCACHE_ALIGN in SLUB to follow the
semantics of SLAB?
