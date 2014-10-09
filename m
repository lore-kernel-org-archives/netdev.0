From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next] r8152: add rtnl_lock
Date: Thu, 9 Oct 2014 07:59:35 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EC397E@RTITMBSTEMP01.realtek.com.tw>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
 <1394712342-15778-59-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-59-Taiwan-albertk@realtek.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Hayes Wang 
> Sent: Thursday, October 09, 2014 2:25 PM
> To: netdev@vger.kernel.org
> Cc: nic_swsd; linux-kernel@vger.kernel.org; 
> linux-usb@vger.kernel.org; Hayes Wang
> Subject: [PATCH net-next] r8152: add rtnl_lock
> 
> Add rtnl_lock() for suspend/resume and workqueue.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Excuse me. The patch has the dead lock issue when
enabling autosuspend. Please ignore this patch.
 
Best Regards,
Hayes
