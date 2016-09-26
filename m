From: Randy Li <randy.li@rock-chips.com>
Subject: About 1000Mbps capability for the GMAC of RK3288
Date: Mon, 26 Sep 2016 10:34:47 +0800
Message-ID: <59dce986-a86c-53d1-065f-ead93735e763@rock-chips.com>
References: <3b81dc49-06ce-30d2-fc35-ee5a3a691e6a@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: "linux-rockchip@lists.infradead.org"
        <linux-rockchip@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3b81dc49-06ce-30d2-fc35-ee5a3a691e6a@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have confirmed the 1000Mbps won't work with kernel 4.4, I have to 
disable it in dts.
The TRM shows that it may not support 1000Mbps, as the gmac_speed in 
GRF_SOC_CON1 is just a bit length flag.
Also I have test the performance at the firefly plus with upstream 
kernel, it even looks bad at 100Mpbs mode, only 5~6 MBytes per second. I 
wonder whether it is the hardware design problem or some problem in 
driver, I would report if I got more information.


-------- Forwarded Message --------
Subject: About 1000Mbps with RK3288 and performance
Date: Tue, 20 Sep 2016 09:31:57 +0800
From: Randy Li <randy.li@rock-chips.com>
Organization: Fuzhou Rockchip
To: david.wu@rock-chips.com
CC: roger.chen@rock-chips.com

Hello Wu
    Have you guys confirmed the RK3288 EVB with 1000Mbps network? I meet 
this issue in the weekend. The kernel is 4.4, when I connected the board 
into a 1000Mbps switch(Dell PowerConnect Serial), the speed negatived 
1000Mbps at both side(I checked with console in switch), but the network 
can't work at all. I have downgrade the speed to 100Mbps or packages 
loss is nearly 100%.
    Also I have been reported with performance of ethernet in Upstream 
kernel, it could barely 5-6MBytes in my test, do you have some idea 
about this?
    You could dial internal number 8308 to talk with me.
							Yours Randy

-- 
Randy Li
The third produce department
===========================================================================
This email message, including any attachments, is for the sole
use of the intended recipient(s) and may contain confidential and
privileged information. Any unauthorized review, use, disclosure or
distribution is prohibited. If you are not the intended recipient, please
contact the sender by reply e-mail and destroy all copies of the original
message. [Fuzhou Rockchip Electronics, INC. China mainland]
===========================================================================
