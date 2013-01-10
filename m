From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5 02/14] bridge: Add vlan filtering
 infrastructure
Date: Thu, 10 Jan 2013 10:36:14 -0800
Message-ID: <20130110103614.23383079@nehalam.linuxnetplumber.net>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
	<1357751882-8619-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1357751882-8619-3-git-send-email-vyasevic@redhat.com>
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

This patch has some minor whitespace and spelling errors:

WARNING: line over 80 characters
#429: FILE: net/bridge/br_private.h:205:
+static inline struct net_bridge_port *vlans_to_port(struct net_port_vlans *vlans)

ERROR: trailing whitespace
#432: FILE: net/bridge/br_private.h:208:
+       $

WARNING: please, no spaces at the start of a line
#432: FILE: net/bridge/br_private.h:208:
+       $

+/* Must be protected by RTNL */
+static void br_vlan_del(struct net_bridge_vlan *vlan)

+	/* Drop the self-ref to trigger descrution. */
                                        ^^^^^^^^^^

Also, the data structure vlan's seems inverted. Why do you keep a hash list
of vlan's and then a bitmap of ports. Seems more natural to just put a bitmap
on each port that has vlan filtering rather than introducing yet another list
to manage.
