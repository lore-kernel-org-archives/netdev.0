From: "David S. Miller" <davem@redhat.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 14:07:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911140746.4f0384a1.davem@redhat.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	<3F60CA6D.9090503@pobox.com>
	<3F60D0F3.8080006@candelatech.com>
	<20030911131219.0ab8dfdd.davem@redhat.com>
	<3F60DDCC.5020906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F60DDCC.5020906@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003 13:40:44 -0700
Ben Greear <greearb@candelatech.com> wrote:

> So, assume we configure a 10MB socket send queue on our UDP socket...
> 
> Select says its writable up to at least 5MB.
> 
> We write 5MB of 64byte packets "righ now".
> 
> Did we just drop a large number of packets?

Yes, we did _iff_ dev->tx_queue_len is less than or equal
to (5MB / (64 + sizeof(udp_id_headers))).
