From: David Coulson <david@davidcoulson.net>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 07:05:43 -0500
Message-ID: <41F63617.8090307@davidcoulson.net>
References: <41F50B6C.6010107@davidcoulson.net>	<20050124151510.GV23931@postel.suug.ch>	<20050124225423.GA15405@gondor.apana.org.au>	<20050124234515.GA31837@postel.suug.ch>	<20050125000759.GA15883@gondor.apana.org.au>	<20050124164049.3b939791.davem@davemloft.net>	<20050125014538.GB31837@postel.suug.ch>	<20050125014838.GA16637@gondor.apana.org.au>	<20050125020118.GC31837@postel.suug.ch>	<20050124180354.63ae600d.davem@davemloft.net>	<20050125022431.GD31837@postel.suug.ch> <20050124194328.20a106de.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, herbert@gondor.apana.org.au, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050124194328.20a106de.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> For example, it probably only works properly when HW vlan assist
> is being used on TX.  It's likely that the chips which don't support
> VLAN assist also can't handle VLAN headers in their TX checksumming
> engine.

This is in acenic.c - ACENIC_DO_VLAN is a check to see if 8021q is 
compiled into the kernel or available as a module.

#if ACENIC_DO_VLAN
         dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
         dev->vlan_rx_register = ace_vlan_rx_register;
         dev->vlan_rx_kill_vid = ace_vlan_rx_kill_vid;
#endif

David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
