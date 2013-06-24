From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vhost-net: fix use-after-free in vhost_net_flush
Date: Mon, 24 Jun 2013 00:01:27 -0700 (PDT)
Message-ID: <20130624.000127.3603241221368993.davem@davemloft.net>
References: <20130620114813.GA17373@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130620114813.GA17373@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 20 Jun 2013 14:48:13 +0300

> vhost_net_ubuf_put_and_wait has a confusing name:
> it will actually also free it's argument.
> Thus since commit 1280c27f8e29acf4af2da914e80ec27c3dbd5c01

Never reference commits only by SHA1 ID, it is never sufficient.

Always provide, after the SHA1 ID, in parenthesis, the header line
from the commit message.

To be honest, I'm kind of tired of telling people they need to do
this over and over again.

Maybe people keep forgetting because the reason why this is an issue
hasn't really sunk in.

If the patch you reference got backported into another tree, it will
not have the SHA1 ID, and therefore someone reading the "fix" won't
be able to find the fault causing change without going through a lot
of trouble.  By providing the commit header line you remove that
problem altogether, no ambiguity is possible.
