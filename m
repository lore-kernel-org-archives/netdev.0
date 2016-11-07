From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Mon, 07 Nov 2016 11:32:25 +0100
Message-ID: <1478514745.2400.3.camel@suse.com>
References: <Pine.LNX.4.44L0.1611040923110.6787-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kai-Heng Feng <kai.heng.feng@canonical.com>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1611040923110.6787-100000@netrider.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-11-04 at 09:26 -0400, Alan Stern wrote:
> On Fri, 4 Nov 2016, Kai-Heng Feng wrote:
> 
> > Sometimes cdc_mbim failed to probe if runtime pm is enabled:
> > [    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22
> > 
> > This can be solved by increase its pm usage counter.
> 
> This should not be needed.  The USB core increments the PM usage 
> counter of a device before probing its interfaces.

Indeed. Yet we have experimental evidence.

Kai-Heng Feng, could you please enable dynamic debugging
for 
drivers/usb/core/driver.c

so that we can see what is going on with the usage counters?

	Regards
		Oliver
