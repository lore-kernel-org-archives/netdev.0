From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] vhost: Drop linux/socket.h
Date: Fri, 16 Aug 2013 09:27:43 +0800
Message-ID: <20130816012743.GA5944@hj.localdomain>
References: <1376536816-10951-1-git-send-email-asias@redhat.com>
	<20130815.140740.1781732332793977170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130815.140740.1781732332793977170.davem@davemloft.net>
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

On Thu, Aug 15, 2013 at 02:07:40PM -0700, David Miller wrote:
> From: Asias He <asias@redhat.com>
> Date: Thu, 15 Aug 2013 11:20:16 +0800
> 
> > memcpy_fromiovec is moved to lib/iovec.c. No need to include
> > linux/socket.h for it.
> > 
> > Signed-off-by: Asias He <asias@redhat.com>
> 
> You can't do this.
> 
> Because this file doesn't include the header file that
> provides the declaration, which is linux/uio.h

vhost.c includes drivers/vhost/vhost.h. In drivers/vhost/vhost.h, we
have linux/uio.h included.

> linux/socket.h includes linux/uio.h, so honestly leaving
> things the way they are is a 1000 times better than your
> patch.

Vhost is a separate module and a generic infrastructure which is not
bound to network anymore. I guess it's better to include the real one
instead of the socket one.

-- 
Asias
