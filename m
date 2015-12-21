From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] BugFix in XHCI controller driver for scatter gather DMA
Date: Mon, 21 Dec 2015 13:50:24 +0100
Message-ID: <1450702224.17967.18.camel@suse.de>
References: <1450699494-4598-1-git-send-email-vikas.bansal@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, sumit.batra@samsung.com
To: Vikas Bansal <vikas.bansal@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450699494-4598-1-git-send-email-vikas.bansal@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-12-21 at 17:34 +0530, Vikas Bansal wrote:
> Pre-Condition
> At the time of reset resume of a USB device, both self and bus powered devices might go to a low power state or power off state depending on the acceptable suspend time power of the system.    
> In case the device experiences a power glitch or completely powers off during suspend-resume, the device will lose its internal state and hence it'll again need a set interface from class driver on reset resume operation.
> 
> Issue 
> So far our experiments were based on a USB gadget working on cdc_eem protocol. 
> We have seen that device is unable to continue the packet transfer on bulk endpoints after the reset resume operation.
> 
> Solution
> We have added a .reset_resume function for cdc_eem protocol which sends a set interface command on the Control endpoint. And calls the existing usbnet_resume thereafte

Hi,

something is wrong with your subject line. Could you fix
that and resend?

	Regards
		Oliver
