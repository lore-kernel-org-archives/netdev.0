From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Sun, 4 Oct 2009 14:24:50 +0400
Message-ID: <20091004102450.GB2569@ioremap.net>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <linux-fbdev-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-fbdev-devel>,
	<mailto:linux-fbdev-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-fbdev-devel>
List-Post: <mailto:linux-fbdev-devel@lists.sourceforge.net>
List-Help: <mailto:linux-fbdev-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-fbdev-devel>,
	<mailto:linux-fbdev-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-fbdev-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2009 at 02:40:03PM +0200, Philipp Reisner (philipp.reisner@linbit.com) wrote:
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

How expressive! :)

> Patches 1 to 4 are already Acked-by Evgeny, the connector's maintainer.
> Patches 5 to 7 are the obvious fixes to the connector user's code.

I ack those changes either since they do not affect logic of the user.

-- 
	Evgeniy Polyakov

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
