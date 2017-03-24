From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: bridge: allow user-space to
 add ext learned entries
Date: Fri, 24 Mar 2017 12:31:29 -0700 (PDT)
Message-ID: <20170324.123129.1392093132050044308.davem@davemloft.net>
References: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, idosch@mellanox.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 23 Mar 2017 12:27:11 +0200

> This set adds the ability to add externally learned entries from
> user-space. For symmetry and proper function we need to allow SW entries
> to take over HW learned ones (similar to how HW can take over SW entries
> currently) which is needed for our use case (evpn) where we have pure SW
> ports and HW ports mixed in a single bridge. This does not play well with
> switchdev devices currently because there's no feedback when the entry is
> taken over, but this case has never worked anyway and feedback can be
> easily added when needed.
> Patch 02 simply allows to use NTF_EXT_LEARNED from user-space, we already
> have Quagga patches that make use of this functionality.

Series applied.
