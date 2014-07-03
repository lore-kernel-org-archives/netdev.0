From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCHv2 net-next] net: filter: move load_pointer() into filter.h
Date: Thu, 03 Jul 2014 17:03:22 +0200
Message-ID: <53B570BA.7080703@redhat.com>
References: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404399414-32099-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/03/2014 04:56 PM, Zi Shen Lim wrote:
> load_pointer() is already a static inline function.
> Let's move it into filter.h so BPF JIT implementations can reuse this
> function.
>
> Since we're exporting this function, let's also rename it to
> bpf_load_pointer() for clarity.
>
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>

Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
