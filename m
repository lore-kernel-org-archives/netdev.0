From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] vsock: Fix blocking ops call in prepare_to_wait
Date: Sat, 13 Feb 2016 05:59:40 -0500 (EST)
Message-ID: <20160213.055940.1894427692019983187.davem@davemloft.net>
References: <1454611845-5358-1-git-send-email-labbott@fedoraproject.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: asarwade@vmware.com, thellstrom@vmware.com, jhansen@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: labbott@fedoraproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454611845-5358-1-git-send-email-labbott@fedoraproject.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Abbott <labbott@fedoraproject.org>
Date: Thu,  4 Feb 2016 10:50:45 -0800

> We receoved a bug report from someone using vmware:
 ...
> transport->stream_enqueue may call copy_to_user so it should
> not be called inside a prepare_to_wait. Narrow the scope of
> the prepare_to_wait to avoid the bad call. This also applies
> to vsock_stream_recvmsg as well.
> 
> Reported-by: Vinson Lee <vlee@freedesktop.org>
> Tested-by: Vinson Lee <vlee@freedesktop.org>
> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>

Applied.
