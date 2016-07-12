From: =?UTF-8?B?TWljaGHFgg==?= Pecio <michal.pecio@gmail.com>
Subject: Re: [PATCH v6 RESEND] r8152: Add support for setting pass through
 MAC address on RTL8153-AD
Date: Tue, 12 Jul 2016 09:02:48 +0200
Message-ID: <20160712090248.7b5633e5@sauron>
References: <1468285084-26557-1-git-send-email-mario_limonciello@dell.com>
	<20160711.194246.742914205682079488.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mario_limonciello@dell.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	anthony.wong@canonical.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160711.194246.742914205682079488.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Mario Limonciello <mario_limonciello@dell.com>
> Date: Mon, 11 Jul 2016 19:58:04 -0500
> 
> > The RTL8153-AD supports a persistent system specific MAC address.
> > This means a device plugged into two different systems with host
> > side support will show different (but persistent) MAC addresses.
> > 
> > This information for the system's persistent MAC address is burned
> > in when the system HW is built and available under \_SB.AMAC in the
> > DSDT at runtime.
> > 
> > This technology is currently implemented in the Dell TB15 and WD15
> > Type-C docks.  More information is available here:
> > http://www.dell.com/support/article/us/en/04/SLN301147
> > 
> > Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>  
> 
> Applied.

Hi,

Isn't it possible that the same ACPI name could be used for other
vendor-specific extensions on other laptops and that r8152 will now
wreak havoc there?

Regards,
MP
