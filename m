From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v1 7/7] bpf: Always test unprivileged programs
Date: Mon, 06 Feb 2017 16:43:59 +0100
Message-ID: <589899BF.60007@iogearbox.net>
References: <20170205231428.23846-1-mic@digikod.net> <20170205231428.23846-7-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170205231428.23846-7-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/06/2017 12:14 AM, Mickaël Salaün wrote:
> If selftests are run as root, then execute the unprivileged checks as
> well. This switch from 240 to 364 tests.
>
> The test numbers are suffixed with "/u" when executed as unprivileged or
> with "/p" when executed as privileged.
>
> The geteuid() check is replaced with a capability check.
>
> Handling capabilities require the libcap dependency.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Shuah Khan <shuah@kernel.org>

Very useful! Could probably also go as stand-alone to net-next,
but how you prefer.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
