From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 3/3] bpf: Always test unprivileged programs
Date: Mon, 06 Feb 2017 23:44:58 +0100
Message-ID: <5898FC6A.5020505@iogearbox.net>
References: <20170206205225.32233-1-mic@digikod.net> <20170206205225.32233-3-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206205225.32233-3-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/06/2017 09:52 PM, Mickaël Salaün wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
