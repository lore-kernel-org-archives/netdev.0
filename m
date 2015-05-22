From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix parsing of MLDv2 reports
Date: Fri, 22 May 2015 15:09:03 -0400 (EDT)
Message-ID: <20150522.150903.570785706419447424.davem@davemloft.net>
References: <1432307939-19640-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Rik.Theys@esat.kuleuven.be
To: cascardo@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1432307939-19640-1-git-send-email-cascardo@redhat.com>
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

From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Date: Fri, 22 May 2015 12:18:59 -0300

> When more than a multicast address is present in a MLDv2 report, all but
> the first address is ignored, because the code breaks out of the loop if
> there has not been an error adding that address.
> 
> This has caused failures when two guests connected through the bridge
> tried to communicate using IPv6. Neighbor discoveries would not be
> transmitted to the other guest when both used a link-local address and a
> static address.
> 
> This only happens when there is a MLDv2 querier in the network.
> 
> The fix will only break out of the loop when there is a failure adding a
> multicast address.
 ...
> Reported-by: Rik Theys <Rik.Theys@esat.kuleuven.be>
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Tested-by: Rik Theys <Rik.Theys@esat.kuleuven.be>

Applied and queued up for -stable, thanks.
