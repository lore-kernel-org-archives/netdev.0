From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ARM: net: add JIT support for loads from struct
 seccomp_data.
Date: Sat, 09 May 2015 22:28:58 -0400 (EDT)
Message-ID: <20150509.222858.26253293963482182.davem@davemloft.net>
References: <1431003613-16554-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, dborkman@redhat.com, ast@plumgrid.com,
	mgherzan@gmail.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431003613-16554-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Thu,  7 May 2015 15:00:13 +0200

> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> ---
> 
> This patch was first sent as part of a serie modifying the core
> seccomp code to allow the use of the classic BPF JIT. As the core
> changes have been submitted to netdev by Daniel Borkmann, it is now
> time to re-submit this patch separately.
> 
> While not physically dependent of the core seccomp changes they are
> needed for the code added in this patch to be triggered.

Where would you like this to be applied, my tree?

This is an ongoing situation, where people have traditionally not
consistently wanted bpf JIT patches to go into the networking tree.

So I beg everyone posting such things to netdev to be _clear_
and _explicit_ about whether you expect me to integrate the patch
or not.

Thanks.
