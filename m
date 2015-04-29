From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net/macb: Fix UDPv4 checksum offload
Date: Wed, 29 Apr 2015 12:03:08 -0400 (EDT)
Message-ID: <20150429.120308.467089046514986430.davem@davemloft.net>
References: <20150427.224713.291017556251723132.davem@davemloft.net>
	<553FEF66.7010503@ni.com>
	<20150429111521.288902f6@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jaeden.amero@ni.com, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeff.westfahl@ni.com, mihai.neagu@ni.com
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150429111521.288902f6@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Wed, 29 Apr 2015 11:15:21 +0100

>> Unfortunately, the Cadence MACB doesn't support the enabling or
>> disabling of checksum generation per descriptor.
> 
> So how does packet forwarding work ?

Yeah actually rechecksumming in that scenerio is illegal.
