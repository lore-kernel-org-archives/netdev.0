From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/unix: drop obsolete fd-recursion limits
Date: Mon, 17 Jul 2017 08:58:21 -0700 (PDT)
Message-ID: <20170717.085821.179430433629233314.davem@davemloft.net>
References: <20170717093554.16459-1-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, teg@jklm.no, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, linux-kernel@vger.kernel.org,
        alban.crequy@collabora.co.uk, simon.mcvittie@collabora.co.uk
To: dh.herrmann@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717093554.16459-1-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Herrmann <dh.herrmann@gmail.com>
Date: Mon, 17 Jul 2017 11:35:54 +0200

 ...
> With all of this in mind, lets drop the recursion limit. It has no
> additional security value, anymore. On the contrary, it randomly
> confuses message brokers that try to forward file-descriptors, since
> any sendmsg(2) call can fail spuriously with ETOOMANYREFS if a client
> maliciously modifies the FD while inflight.
> 
> Cc: Alban Crequy <alban.crequy@collabora.co.uk>
> Cc: Simon McVittie <simon.mcvittie@collabora.co.uk>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

Applied, thanks.
