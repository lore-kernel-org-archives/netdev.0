From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] unexport ei_tx_timeout
Date: Sat, 30 Oct 2004 08:37:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41838B08.8070709@pobox.com>
References: <20041024131256.GC19567@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041024131256.GC19567@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> not used by any module, and the API doesn't make sense as export either

next time include a signed-off-by line.

Also, the API _does_ make sense as an export, as it is a generic helper 
that can be plugged directly into the netdev->tx_timeout hook.

However, I applied your patch due to the first argument -- no users.

	Jeff
