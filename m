From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vsock: Make transport the proto owner
Date: Mon, 05 May 2014 13:14:37 -0400 (EDT)
Message-ID: <20140505.131437.1075882730518482984.davem@davemloft.net>
References: <1398982843-1453-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, pv-drivers@vmware.com,
	stable@vger.kernel.org
To: acking@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398982843-1453-1-git-send-email-acking@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy King <acking@vmware.com>
Date: Thu,  1 May 2014 15:20:43 -0700

> Right now the core vsock module is the owner of the proto family. This
> means there's nothing preventing the transport module from unloading if
> there are open sockets, which results in a panic. Fix that by allowing
> the transport to be the owner, which will refcount it properly.
> 
> Includes version bump to 1.0.1.0-k
> 
> Passes checkpatch this time, I swear...
> 
> Cc: stable@vger.kernel.org

Please do not explicitly CC: stable for networking submissions, instead please
just ask me to queue it up for -stable submission since I handle networking
-stable myself.

> Acked-by: Dmitry Torokhov <dtor@vmware.com>
> Signed-off-by: Andy King <acking@vmware.com>

Applied, thanks.
