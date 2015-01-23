From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 2/2] samples: bpf: relax test_maps check
Date: Fri, 23 Jan 2015 11:58:00 +0100
Message-ID: <54C22938.3070709@redhat.com>
References: <1421975469-13035-1-git-send-email-ast@plumgrid.com> <1421975469-13035-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421975469-13035-3-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/23/2015 02:11 AM, Alexei Starovoitov wrote:
> hash map is unordered, so get_next_key() iterator shouldn't
> rely on particular order of elements. So relax this test.
>
> Fixes: ffb65f27a155 ("bpf: add a testsuite for eBPF maps")
> Reported-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
