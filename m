From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: use eth_hw_addr_random() and reset
 addr_assign_type
Date: Wed, 15 Feb 2012 15:34:55 -0500 (EST)
Message-ID: <20120215.153455.1834741004962671833.davem@davemloft.net>
References: <1329324340-13461-1-git-send-email-danny.kukawka@bisect.de>
	<1329324340-13461-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, bridge@lists.linux-foundation.org, jpirko@redhat.com,
	netdev@vger.kernel.org, jesse@nicira.com, dkukawka@suse.de,
	linux-kernel@vger.kernel.org, cmetcalf@tilera.com,
	eilong@broadcom.com, steve.glendinning@smsc.com, shemminger@vyatta.com
To: danny.kukawka@bisect.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1329324340-13461-3-git-send-email-danny.kukawka@bisect.de>
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

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Wed, 15 Feb 2012 17:45:40 +0100

> Use eth_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> v2: adapt to renamed eth_hw_addr_random()
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied.
