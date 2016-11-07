From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Mon, 07 Nov 2016 12:02:05 +0100
Message-ID: <1478516525.2400.4.camel@suse.com>
References: <20161104095735.21071-1-kai.heng.feng@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Kai-Heng Feng <kai.heng.feng@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104095735.21071-1-kai.heng.feng@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-11-04 at 17:57 +0800, Kai-Heng Feng wrote:
> Sometimes cdc_mbim failed to probe if runtime pm is enabled:
> [    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22
> 
> This can be solved by increase its pm usage counter.
> 
> Signed-off-by: Kai-Heng Feng <kai.heng.feng@canonical.com>

For the record:

NAK. This fixes a symptom. If this patch helps something is broken in
device core. We need to find that.

	Regards
		Oliver
