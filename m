From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V2 net-next 4/6] test_bpf: add module parameters to filter
 the tests to run.
Date: Tue, 4 Aug 2015 08:46:37 -0700
Message-ID: <55C0DE5D.3040904@plumgrid.com>
References: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
 <1438694352-17469-5-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438694352-17469-5-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/15 6:19 AM, Nicolas Schichan wrote:
> When developping on the interpreter or a particular JIT, it can be
> interesting to restrict the tests list to a specific test or a
> particular range of tests.
>
> This patch adds the following module parameters to the test_bpf module:
>
> * test_name=<string>: only the specified named test will be run.
>
> * test_id=<number>: only the test with the specified id will be run
>    (see the output of test_bpf without parameters to get the test id).
>
> * test_range=<number>,<number>: only the tests within IDs in the
>    specified id range are run (see the output of test_bpf without
>    parameters to get the test ids).
>
> Any invalid range, test id or test name will result in -EINVAL being
> returned and no tests being run.
>
> Signed-off-by: Nicolas Schichan<nschichan@freebox.fr>
> Acked-by: Daniel Borkmann<daniel@iogearbox.net>

looks good. thank you for adding range feature :)
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
