From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: use correct ether type for alb
Date: Fri, 14 Mar 2014 22:21:33 -0400 (EDT)
Message-ID: <20140314.222133.1978976674383447094.davem@davemloft.net>
References: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	stefanr@s5r6.in-berlin.de, sw@simonwunderlich.de,
	Neil.Jerram@metaswitch.com, horms@verge.net.au,
	Arvid.Brodin@xdin.com, linux-kernel@vger.kernel.org
To: vfalico@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 13 Mar 2014 12:41:56 +0100

> There have been reports that, while using the ETH_P_LOOP ether type
> (0x0060), the ether type is treated as its packet length.
> 
> To avoid that and to not break already existing apps - add new ether type
> ETH_P_LOOPBACK that contains the correct id - 0x9000.

Series applied, thanks Veaceslav.
