From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net-next 0/3] r8152: configuration setting
Date: Thu, 08 Sep 2016 15:08:12 +0200
Message-ID: <1473340092.32073.4.camel@suse.com>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
         <87h99rizsi.fsf@miraculix.mork.no>
         <0835B3720019904CB8F7AA43166CEEB2010259B5@RTITMBSV03.realtek.com.tw>
         <87vay6hlmc.fsf@miraculix.mork.no>
         <0835B3720019904CB8F7AA43166CEEB201026170@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201026170@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-08 at 13:02 +0000, Hayes Wang wrote:
> I tested above method before. And I found that the cdc_ether 
> was loaded before switching the configuration. The behavior 
> of loading one driver and changing to another driver has 
> opportunity to let our some previous chips become abnormal. 
> To switch configuration is fine. However, it may have problem 
> to switch driver. That is why the current kernel only supports 
> vendor mode. If the method works fine, I have no trouble now.

We may talk about creating extensions to cdc-ether, if they
are needed for the phy. What is unacceptable is to override
the configuration mechanism in the kernel.

	Regards
		Oliver
