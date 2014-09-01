From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v2] r8152: reduce the number of Tx
Date: Mon, 1 Sep 2014 02:46:38 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2516A75@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-23-Taiwan-albertk@realtek.com>
	<1394712342-15778-24-Taiwan-albertk@realtek.com>
 <20140829.202504.655684636693672249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140829.202504.655684636693672249.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From: David Miller [mailto:davem@davemloft.net] 
[...]
> This driver has a loop that iterates MAX_TX times to initialize both
> the RX and TX buffers.
> 
> So if they are not equal, it can't possibly work.

Excuse me. I don't find that the "RTL8152_MAX_TX" is used by
rx buffer. The rx buffer only use "RTL8152_MAX_RX". Although 
the tx buffer size is determined by "rx_buf_sz", the tx buffers
are independent of rx buffers.

Best Regards,
Hayes
