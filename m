From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Mon, 09 Feb 2004 12:34:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4027EECA.9000705@us.ibm.com>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain> <20040206194518.56787717.davem@redhat.com> <Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:

> ChangeSet@1.1551, 2004-02-09 11:14:24-08:00, sri@us.ibm.com
>   [SCTP] Removed SCTP specific rmem/wmem sysctl's and use the global
>          rmem_default/wmem_default values for SCTP socket buffer sizes.

Sorry to pitch in on this so late - and I'm not suggesting
this was not the right thing to do here, but I feel that
having the per-protocol globals (as we do for TCP) is a
good thing, as then you don't affect all (raw, udp..)
traffic on the system just because someone is tuning
for SCTP, etc.

Just my 0.2c :)

thanks,
Nivedita
