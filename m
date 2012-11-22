From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: Re: [PATCH V3] xen/netfront: handle compound page
 fragments on transmit
Date: Thu, 22 Nov 2012 09:15:52 -0500
Message-ID: <20121122141551.GA20186@konrad-lan.dumpdata.com>
References: <1353499336-28952-1-git-send-email-ian.campbell@citrix.com>
	<20121121151625.GA13127@konrad-lan.dumpdata.com>
	<20121121.114957.441218567286373485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org, edumazet@google.com,
	stefan.bader@canonical.com, xen-devel@lists.xen.org,
	linux@eikelenboom.it, annie.li@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <20121121.114957.441218567286373485.davem@davemloft.net>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2012 at 11:49:57AM -0500, David Miller wrote:
> From: Konrad Rzeszutek Wilk <konrad@kernel.org>
> Date: Wed, 21 Nov 2012 10:16:27 -0500
> 
> > On Wed, Nov 21, 2012 at 12:02:16PM +0000, Ian Campbell wrote:
> >> An SKB paged fragment can consist of a compound page with order > 0.
> >> However the netchannel protocol deals only in PAGE_SIZE frames.
> >> 
> >> Handle this in xennet_make_frags by iterating over the frames which
> >> make up the page.
> >> 
> >> This is the netfront equivalent to 6a8ed462f16b for netback.
> >> 
> >> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> >> Cc: netdev@vger.kernel.org
> >> Cc: xen-devel@lists.xen.org
> >> Cc: Eric Dumazet <edumazet@google.com>
> >> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
> > 
> > Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > 
> > David, would you like me to send it to Linus via my tree or are you
> > OK sending him a git pull with this patch (and hopefully some other
> > ones?)
> 
> I'll merge this to Linus via my net tree, thanks.

Great. Thank you for doing it at such short notice and sooo close to the release.
