From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC] bpf: change bpf syacall to use u64 temp variables
Date: Mon, 19 Oct 2015 10:55:22 +0200
Message-ID: <5624AFFA.2010209@iogearbox.net>
References: <1445238646-9379-1-git-send-email-yalin.wang2010@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: yalin wang <yalin.wang2010@gmail.com>, ast@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445238646-9379-1-git-send-email-yalin.wang2010@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2015 09:10 AM, yalin wang wrote:
> This patch change map_lookup_elem() and map_update_elem() function
> to use u64 temp variable if the key_size or value_size is less than
> u64, we don't need use kmalloc() for these small variables.
>
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

 From an application PoV that has to make the bpf(2) syscall, how
much do we actually gain from this? I'm curious, did you perform
some benchmarks that show a noticeable difference?
