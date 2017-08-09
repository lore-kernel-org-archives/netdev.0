From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] bpf: Extend check_uarg_tail_zero()
 checks
Date: Tue, 08 Aug 2017 18:11:33 -0700 (PDT)
Message-ID: <20170808.181133.1654188772199067010.davem@davemloft.net>
References: <20170807184520.8130-1-mic@digikod.net>
        <20170807184520.8130-2-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        keescook@chromium.org, kafai@fb.com, netdev@vger.kernel.org,
        ast@kernel.org
To: mic@digikod.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807184520.8130-2-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>
Date: Mon,  7 Aug 2017 20:45:20 +0200

> The function check_uarg_tail_zero() was created from bpf(2) for
> BPF_OBJ_GET_INFO_BY_FD without taking the access_ok() nor the PAGE_SIZE
> checks. Make this checks more generally available while unlikely to be
> triggered, extend the memory range check and add an explanation
> including why the ToCToU should not be a security concern.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Martin KaFai Lau <kafai@fb.com>
> Link: https://lkml.kernel.org/r/CAGXu5j+vRGFvJZmjtAcT8Hi8B+Wz0e1b6VKYZHfQP_=DXzC4CQ@mail.gmail.com

Applied.
