From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v2 3/3] bpf: Always test unprivileged programs
Date: Mon, 6 Feb 2017 13:19:10 -0800
Message-ID: <5898E84E.7080507@fb.com>
References: <20170206205225.32233-1-mic@digikod.net>
 <20170206205225.32233-3-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206205225.32233-3-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/6/17 12:52 PM, Mickaël Salaün wrote:
> If selftests are run as root, then execute the unprivileged checks as
> well. This switch from 240 to 364 tests.
>
> The test numbers are suffixed with "/u" when executed as unprivileged or
> with "/p" when executed as privileged.
>
> The geteuid() check is replaced with a capability check.
>
> Handling capabilities requires the libcap dependency.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Shuah Khan <shuah@kernel.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>

you can keep acks when there are no changes to the patch.
