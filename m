From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] bpf: hash: move select_bucket() out of htab's spinlock
Date: Mon, 28 Dec 2015 10:04:14 +0100
Message-ID: <5680FB0E.7010400@iogearbox.net>
References: <1451122294-16524-1-git-send-email-tom.leiming@gmail.com> <1451122294-16524-3-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451122294-16524-3-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/26/2015 10:31 AM, Ming Lei wrote:
> The spinlock is just used for protecting the per-bucket
> hlist, so it isn't needed for selecting bucket.
>
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
