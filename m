From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Sat, 21 Oct 2017 09:00:25 -0700
Message-ID: <20171021160025.GM1302522@devbig577.frc2.facebook.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
 <20171018132526.GC1302522@devbig577.frc2.facebook.com>
 <20171018214508.GA12295@localhost.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
        ast@kernel.org, john.fastabend@gmail.com, mark.rutland@arm.com,
        richard@nod.at, sp3485@columbia.edu, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dennis Zhou <dennisszhou@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171018214508.GA12295@localhost.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Oct 18, 2017 at 04:45:08PM -0500, Dennis Zhou wrote:
> I'm not sure I see the reason we can't match the minimum allocation size
> with the unit size? It seems weird to arbitrate the maximum allocation
> size given a lower bound on the unit size.

idk, it can be weird for the maximum allowed allocation size varying
widely depending on how the machine boots up.

Thanks.

-- 
tejun
