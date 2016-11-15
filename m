From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Tue, 15 Nov 2016 02:10:44 +0100
Message-ID: <20161115011044.GA13220@electric-eye.fr.zoreil.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161111121311.GA19673@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB20104EAF8@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "mlord@pobox.com" <mlord@pobox.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20104EAF8@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Francois Romieu [mailto:romieu@fr.zoreil.com]
> > Sent: Friday, November 11, 2016 8:13 PM
> [...]
> > Invalid packet size corrupted receive descriptors in Realtek's device
> > reminds of CVE-2009-4537.
> 
> Do you mean that the driver would get a packet exceed the size
> which is set to RxMaxSize ?

If it was possible to get it wrong once, it should be possible to
get it wrong twice, especially if some part of the hardware design
is recycled. I don't mean anything else.

I won't speculate about some cache consistency issue or some badly
aborted dma transaction to explain the memory corruption.

-- 
Ueimor
