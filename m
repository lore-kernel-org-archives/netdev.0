From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v2 2/3] r8152: clear theflagofSCHEDULE_TASKLETin tasklet
Date: Mon, 3 Nov 2014 12:35:29 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ECD9F4@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-75-Taiwan-albertk@realtek.com>
 <1394712342-15778-79-Taiwan-albertk@realtek.com>
 <1394712342-15778-81-Taiwan-albertk@realtek.com>
 <20141031.161520.3547230591227504.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB2ECD8A7@RTITMBSV03.realtek.com.tw>
 <20141102225307.GA19900@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141102225307.GA19900@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> test_and_clear_bit (dense) or clear_bit would be more idiomatic.

Excuse me. If I use clear_bit without test_bit or test_and_clear_bit,
they alwayes call the spin lock. However, for my original flow, the spin
lock is only called when the clear_bit is necessary. Is that better?
 
Best Regards,
Hayes
