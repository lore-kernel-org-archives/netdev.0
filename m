From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/unix: sk_socket can disappear when state is
 unlocked
Date: Tue, 26 May 2015 23:20:00 -0400 (EDT)
Message-ID: <20150526.232000.151948403564280182.davem@davemloft.net>
References: <1432653777-13799-1-git-send-email-salyzyn@android.com>
	<1432675499.2339251.278766569.277AF8B9@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: salyzyn@android.com, hannes@redhat.com,
	linux-kernel@vger.kernel.org, dmitry.tarnyagin@lockless.no,
	viro@zeniv.linux.org.uk, dhowells@redhat.com,
	ying.xue@windriver.com, hch@lst.de, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432675499.2339251.278766569.277AF8B9@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 26 May 2015 23:24:59 +0200

> On Tue, May 26, 2015, at 17:22, Mark Salyzyn wrote:
>> got a rare NULL pointer dereference in clear_bit
>> 
>> Signed-off-by: Mark Salyzyn <salyzyn@android.com>
> 
> IMHO, this is the right approach, I didn't came up with something
> easier, thanks!
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks!
