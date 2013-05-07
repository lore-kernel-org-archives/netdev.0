From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Tue, 07 May 2013 09:22:27 +0400
Message-ID: <51888F93.3030300@openvz.org>
References: <20130505145622.9351.86587.stgit@zurg> <20130506093318.679f5557@redhat.com> <20130506.110800.1388239604905052651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	fw@strlen.de, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130506.110800.1388239604905052651.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jesper Dangaard Brouer<brouer@redhat.com>
> Date: Mon, 6 May 2013 09:33:18 +0200
>
>> This a good fix, and better than my earlier attempt at fixing this.
>   ...
>> Signed-off-by: Jesper Dangaard Brouer<brouer@redhat.com>
>
> Applied, but this patch was generated against a very old tree,
> one before the q->net->nqueues stuff was added.
>
> I sorted out the conflicts but someone needs to double-check
> my work.

All right. Sorry, my patch is against 3.9

Seems like this bug allows to crash kernel remotely.
Should I send it to stable@ for including into 3.9.y or
you already have a bunch of patches for it?
