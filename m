From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH trival -resend 1/2] bpf: clean up put_cpu_var usage
Date: Wed, 28 Sep 2016 01:15:27 +0200
Message-ID: <20160927231527.GB16429@mtj.duckdns.org>
References: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        akpm@linux-foundation.org, Alexei Starovoitov <ast@kernel.org>
To: Shaohua Li <shli@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36075 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbcI0XPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 19:15:32 -0400
Content-Disposition: inline
In-Reply-To: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 08:42:41AM -0700, Shaohua Li wrote:
> put_cpu_var takes the percpu data, not the data returned from
> get_cpu_var.
> 
> This doesn't change the behavior.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
