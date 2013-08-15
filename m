From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: Drop linux/socket.h
Date: Thu, 15 Aug 2013 14:07:40 -0700 (PDT)
Message-ID: <20130815.140740.1781732332793977170.davem@davemloft.net>
References: <1376536816-10951-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, mst@redhat.com
To: asias@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1376536816-10951-1-git-send-email-asias@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>
Date: Thu, 15 Aug 2013 11:20:16 +0800

> memcpy_fromiovec is moved to lib/iovec.c. No need to include
> linux/socket.h for it.
> 
> Signed-off-by: Asias He <asias@redhat.com>

You can't do this.

Because this file doesn't include the header file that
provides the declaration, which is linux/uio.h

linux/socket.h includes linux/uio.h, so honestly leaving
things the way they are is a 1000 times better than your
patch.
