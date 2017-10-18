From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Wed, 18 Oct 2017 08:28:16 -0700
Message-ID: <CAADnVQLk2gu1j3PXjDCfF1hh09-5Ak_8Xd5hq48xTAJNR0Xb=Q@mail.gmail.com>
References: <cover.1508251210.git.daniel@iogearbox.net> <20171018132526.GC1302522@devbig577.frc2.facebook.com>
 <59E75F4F.7070706@iogearbox.net> <59E7639A.4060604@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Richard Weinberger <richard@nod.at>, sp3485@columbia.edu,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Dennis Zhou <dennisszhou@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59E7639A.4060604@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 7:22 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Higher prio imo would be to make the allocation itself faster
> though, I remember we talked about this back in May wrt hashtable,
> but I kind of lost track whether there was an update on this in
> the mean time. ;-)

new percpu allocator by Dennis fixed those issues. It's in 4.14
