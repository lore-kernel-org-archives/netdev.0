From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: mark packets sent to any local mac
 address as PACKET_HOST
Date: Wed, 25 Jun 2014 16:13:35 -0700
Message-ID: <20140625161335.11598f09@haswell>
References: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
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

On Mon, 23 Jun 2014 16:33:35 +0200
Maxime Bizon <mbizon@freebox.fr> wrote:

> The bridge code only set PACKET_HOST on packets sent to the bridge mac
> address, packets sent to other local mac addresses are sent to upper
> layers, but ignored because they are marked as PACKET_OTHERHOST.
> 
> Signed-off-by: Maxime Bizon <mbizon@freebox.fr>

What are you trying to do? Bridge device itself only has one MAC address.
Are you trying to run macvlan on top of bridge?
We only respond to ARP with bridge's MAC address.
