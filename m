From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Part 1: unify return value of
 .ndo_set_mac_address if address is invalid
Date: Thu, 23 Feb 2012 17:12:01 -0500 (EST)
Message-ID: <20120223.171201.453882925963706554.davem@davemloft.net>
References: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, dm@chelsio.com, leedom@chelsio.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	dkukawka@suse.de, linux-kernel@vger.kernel.org,
	cmetcalf@tilera.com, mcarlson@broadcom.com, olof@lixom.net,
	linux-usb@vger.kernel.org, buytenh@wantstofly.org,
	gregkh@linuxfoundation.org, linux-driver@qlogic.com,
	mark.einon@gmail.com, mchan@broadcom.com, jdmason@kudzu.us,
	kristoffer@gaisler.com, shemminger@vyatta.com, divy@chelsio.com
To: danny.kukawka@bisect.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
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
Date: Tue, 21 Feb 2012 13:07:48 +0100

> Here a series of patches to unifiy the return value of 
> .ndo_set_mac_address if the given address isn't valid. 
> Return -EADDRNOTAVAIL as eth_mac_addr() and other 
> .ndo_set_mac_address functions already do if is_valid_ether_addr() 
> fails.
> 
> Other patches will follow if this set gets accepted.

All applied to net-next, thanks.
