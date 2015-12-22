From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Tue, 22 Dec 2015 09:48:05 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
 <20151208143305.GB18728@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Lu Baolu <baolu.lu@linux.intel.com>
To: Peter Wu <peter@lekensteyn.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151208143305.GB18728@al>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Peter Wu [mailto:peter@lekensteyn.nl]
> Sent: Tuesday, December 08, 2015 10:33 PM
[...]
> I found another problem with runtime PM. When a device is suspended via
> autosuspend and a system suspend takes place, there is no network I/O
> after resume. Triggering a renegotiation (ethtool -r eth1) brings back
> network activity.

I think it is relative to the firmware. Could you try the driver from Realtek website?

Best Regards,
Hayes
