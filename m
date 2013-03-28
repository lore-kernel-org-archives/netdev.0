From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] net: add ETH_P_802_3_MIN
Date: Thu, 28 Mar 2013 14:31:29 +0900
Message-ID: <20130328053128.GA23630@verge.net.au>
References: <1364445505-9745-1-git-send-email-horms@verge.net.au>
	<20130328.012108.961738246524996742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, isdn@linux-pingi.de, bridge@lists.linux-foundation.org,
	johan.hedberg@gmail.com, gustavo@padovan.org,
	marcel@holtmann.org, jesse@nicira.com,
	linux-wireless@vger.kernel.org, stephen@networkplumber.org,
	linux-bluetooth@vger.kernel.org, bart.de.schuymer@pandora.be,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux1394-devel@lists.sourceforge.net,
	kaber@trash.net, linux-media@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130328.012108.961738246524996742.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 28, 2013 at 01:21:08AM -0400, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Thu, 28 Mar 2013 13:38:25 +0900
> 
> > Add a new constant ETH_P_802_3_MIN, the minimum ethernet type for
> > an 802.3 frame. Frames with a lower value in the ethernet type field
> > are Ethernet II.
> > 
> > Also update all the users of this value that David Miller and
> > I could find to use the new constant.
> > 
> > Also correct a bug in util.c. The comparison with ETH_P_802_3_MIN
> > should be >= not >.
> > 
> > As suggested by Jesse Gross.
> > 
> > Compile tested only.
> > 
> > Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>
> > Acked-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Looks great, applied, thanks Simon.

Thanks!
