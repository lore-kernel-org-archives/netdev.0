From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/4] bridge: Add sysfs interface to
 control promisc mode
Date: Wed, 13 Mar 2013 08:38:43 -0700
Message-ID: <20130313083843.411b3a6c@nehalam.linuxnetplumber.net>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
	<1363139126-13396-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1363139126-13396-2-git-send-email-vyasevic@redhat.com>
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

On Tue, 12 Mar 2013 21:45:23 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> Add an sysfs interface to turn promiscusous mode on and off on
> the bridge.  By default all interfaces in the bridge
> are in promisc mode.  When promisc mode is turned off, it is
> turned off on all bridge ports and the bridge turns on IFF_ALLMULTI
> to handle multicast traffic.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_device.c   |   41 +++++++++++++++++++++++++++++++++++++++++
>  net/bridge/br_if.c       |   22 +++++++++++++++++-----
>  net/bridge/br_private.h  |    2 ++
>  net/bridge/br_sysfs_br.c |   17 +++++++++++++++++
>  4 files changed, 77 insertions(+), 5 deletions(-)
> 

All attribute changes must also be available through netlink, and changes
to attributes should cause a notification to applications listening for
netlink events on that bridge.
