From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Tue, 17 Oct 2017 15:03:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD009980D@AcuExch.aculab.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tj@kernel.org" <tj@kernel.org>, "ast@kernel.org" <ast@kernel.org>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "richard@nod.at" <richard@nod.at>,
        "sp3485@columbia.edu" <sp3485@columbia.edu>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann
> Sent: 17 October 2017 15:56
> 
> The set fixes a splat in devmap percpu allocation when we alloc
> the flush bitmap. Patch 1 is a prerequisite for the fix in patch 2,
> patch 1 is rather small, so if this could be routed via -net, for
> example, with Tejun's Ack that would be good. Patch 3 gets rid of
> remaining PCPU_MIN_UNIT_SIZE checks, which are percpu allocator
> internals and should not be used.

Does it make sense to allow the user program to try to allocate ever
smaller very large maps until it finds one that succeeds - thus
using up all the percpu space?

Or is this a 'root only' 'shoot self in foot' job?

	David
