From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bug in eBPF verifier
Date: Tue, 21 Oct 2014 21:44:22 -0400 (EDT)
Message-ID: <20141021.214422.448340967510694149.davem@davemloft.net>
References: <1413842097-4380-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, dborkman@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413842097-4380-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 20 Oct 2014 14:54:57 -0700

> while comparing for verifier state equivalency the comparison
> was missing a check for uninitialized register.
> Make sure it does so and add a testcase.
> 
> Fixes: f1bca824dabb ("bpf: add search pruning optimization to verifier")
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
