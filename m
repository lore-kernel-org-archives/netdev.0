From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8152: fix lockup when runtime PM is enabled
Date: Tue, 8 Dec 2015 03:18:59 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F8D48F@RTITMBSV03.realtek.com.tw>
References: <1449507520-10671-1-git-send-email-peter@lekensteyn.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Lu Baolu <baolu.lu@linux.intel.com>
To: Peter Wu <peter@lekensteyn.nl>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449507520-10671-1-git-send-email-peter@lekensteyn.nl>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Wu [mailto:peter@lekensteyn.nl]
> Sent: Tuesday, December 08, 2015 12:59 AM
[...]
> +			if (tp->netdev->flags & IFF_UP) {

Maybe you could just replace the checking of netif_running(tp->netdev) with this.

Excuse me. I have a question. Before the open() is finished, the netif_running() would
be true, but the IFF_UP wouldn't be set. Is it right?

Best Regards,
Hayes
