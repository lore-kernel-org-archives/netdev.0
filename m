From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Question about the hash used in XOR mode
Date: Tue, 23 Sep 2003 13:31:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309232031.h8NKVXNN011694@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Sun, 21 Sep 2003 16:37:37 +0300." <200309211637.37136.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>slave_no = (data->h_dest[5]^slave->dev->dev_addr[5]) % bond->slave_cnt;
[...]
>Is there a special meaning for XORing with a constant ?
>Wouldn't it be the same is we did just:
>	slave_no = data->h_dest[5] % bond->slave_cnt;

	I asked Janice Girouard about this...  The theory is to mimic
the way Cisco etherchannel load balancing modes operate (in particular
I think the "src-dst-mac" mode).

	The Cisco 6000 series switch (and maybe others) documentation
shows the algorithm (in an example; it doesn't go into detail).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
