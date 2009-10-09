From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri, 9 Oct 2009 15:25:05 -0700
Message-ID: <20091009222505.GA28979@kroah.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fbdev-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2009 at 02:40:03PM +0200, Philipp Reisner wrote:
> Affected: All code that uses connector, in kernel and out of mainline
> 
> The connector, as it is today, does not allow the in kernel receiving
> parts to do any checks on privileges of a message's sender.
> 
> I know, there are not many out there that like connector, but as
> long as it is in the kernel, we have to fix the security issues it has!
> 
> Please either drop connector, or someone who feels a bit responsible
> and has our beloved dictator's blessing, PLEASE PLEASE PLEASE take 
> this into your tree, and send the pull request to Linus.
> 
> Patches 1 to 4 are already Acked-by Evgeny, the connector's maintainer.
> Patches 5 to 7 are the obvious fixes to the connector user's code.

These don't apply to the 2.6.31-stable tree at all.

Could you provide them backported to that tree if you want to see them
go into a .31-stable release?

thanks,

greg k-h
