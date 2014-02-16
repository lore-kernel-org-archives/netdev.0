From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v2 1/4] bridge: enable interfaces to opt out from
 becoming the root bridge
Date: Sun, 16 Feb 2014 10:57:54 -0800
Message-ID: <20140216105754.63738163@nehalam.linuxnetplumber.net>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
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

On Fri, 14 Feb 2014 18:59:37 -0800
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> It doesn't make sense for some interfaces to become a root bridge
> at any point in time. One example is virtual backend interfaces
> which rely on other entities on the bridge for actual physical
> connectivity. They only provide virtual access.
> 
> Device drivers that know they should never become part of the
> root bridge have been using a trick of setting their MAC address
> to a high broadcast MAC address such as FE:FF:FF:FF:FF:FF. Instead
> of using these hacks lets the interfaces annotate its intent and
> generalizes a solution for multiple drivers, while letting the
> drivers use a random MAC address or one prefixed with a proper OUI.
> This sort of hack is used by both qemu and xen for their backend
> interfaces.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: bridge@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>

This is already supported in a more standard way via the root
block flag.
