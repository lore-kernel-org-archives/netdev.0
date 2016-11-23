From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Wed, 23 Nov 2016 08:41:29 -0500
Message-ID: <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What does this code do:

>static void r8153_set_rx_early_size(struct r8152 *tp)
>{
>        u32 mtu = tp->netdev->mtu;
>        u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
>
>        ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
>}

How is ocp_data used by the hardware?
Shouldn't the calculation also include sizeof(rx_desc) in there somewhere?

Thanks
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
