From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Tue, 14 Mar 2017 23:29:23 +0100
Message-ID: <58C86EC3.9010406@iogearbox.net>
References: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>
To: David Daney <david.daney@cavium.com>, linux-mips@linux-mips.org,
        ralf@linux-mips.org, James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170314212144.29988-1-david.daney@cavium.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 03/14/2017 10:21 PM, David Daney wrote:
> Changes from v1:
>
>    - Use unsigned access for SKF_AD_HATYPE
>
>    - Added three more patches for other problems found.
>
>
> Testing the BPF JIT on Cavium OCTEON (mips64) with the test-bpf module
> identified some failures and unimplemented features.

Nice, thanks for working on this! If you see specific test
cases for the JIT missing, please also feel free to extend
the test_bpf suite, so this gets exposed further to other
JITs, too.

> With this patch set we get:
>
>       test_bpf: Summary: 305 PASSED, 0 FAILED, [85/297 JIT'ed]
>
> Both big and little endian tested.
>
> We still lack eBPF support, but this is better than nothing.

Any future plans on this one?

Thanks,
Daniel
