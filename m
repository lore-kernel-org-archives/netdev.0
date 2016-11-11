From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Fri, 11 Nov 2016 13:13:11 +0100
Message-ID: <20161111121311.GA19673@electric-eye.fr.zoreil.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        mlord@pobox.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394712342-15778-228-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> For some platforms, the data in memory is not the same with the one
> from the device. That is, the data of memory is unbelievable. The
> check is used to find out this situation.

Invalid packet size corrupted receive descriptors in Realtek's device
reminds of CVE-2009-4537.

Is the silicium of both devices different enough to prevent the same
exploit to happen ?

-- 
Ueimor
