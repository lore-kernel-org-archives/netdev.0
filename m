From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: filter: move load_pointer() into
 filter.h
Date: Tue, 08 Jul 2014 14:11:37 -0700 (PDT)
Message-ID: <20140708.141137.1850005112297468089.davem@davemloft.net>
References: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, ast@plumgrid.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zlim.lnx@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zi Shen Lim <zlim.lnx@gmail.com>
Date: Thu,  3 Jul 2014 07:56:54 -0700

> load_pointer() is already a static inline function.
> Let's move it into filter.h so BPF JIT implementations can reuse this
> function.
> 
> Since we're exporting this function, let's also rename it to
> bpf_load_pointer() for clarity.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> ---
> v1->v2:
> * Renamed to more specific name of bpf_load_pointer(), as suggested
>   by Daniel.

Applied, thank you.
