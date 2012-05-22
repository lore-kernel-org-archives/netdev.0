From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen: do not disable netfront in dom0
Date: Tue, 22 May 2012 20:30:28 +0100
Message-ID: <1337715028.3991.2.camel@dagon.hellion.org.uk>
References: <20120522130558.D828E6C7@duch.mimuw.edu.pl>
	<20120522.151354.2131168749992255398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeremy@goop.org" <jeremy@goop.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"marmarek@invisiblethingslab.com" <marmarek@invisiblethingslab.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120522.151354.2131168749992255398.davem@davemloft.net>
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

On Tue, 2012-05-22 at 20:13 +0100, David Miller wrote:
> From: Marek Marczykowski <marmarek@invisiblethingslab.com>
> Date: Sun, 20 May 2012 13:45:10 +0200
> 
> > Netfront driver can be also useful in dom0, eg when all NICs are assigned to
> > some domU (aka driver domain). Then using netback in domU and netfront in dom0
> > is the only way to get network access in dom0.
> > 
> > Signed-off-by: Marek Marczykowski <marmarek@invisiblethingslab.com>
> 
> Someone please review this and I can merge it in via the 'net' tree if
> it looks OK to XEN folks.

Konrad is "Xen folks" and has acked it already but FWIW:

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ian.

> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
