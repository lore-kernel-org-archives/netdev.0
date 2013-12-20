From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/4] misc: xgene: Add base driver for APM X-Gene SoC
 Queue Manager/Traffic Manager
Date: Thu, 19 Dec 2013 19:21:33 -0800
Message-ID: <20131220032133.GB32310@kroah.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
 <1387507503-7565-3-git-send-email-rapatel@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Keyur Chudgar <kchudgar@apm.com>
To: Ravi Patel <rapatel@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387507503-7565-3-git-send-email-rapatel@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 06:45:01PM -0800, Ravi Patel wrote:
> This patch adds APM X-Gene SoC Queue Manager/Traffic Manager base driver.
>  QMTM is requried by Ethernet, PktDMA and Security Engine subsystems.

How does this driver talk to userspace?  Or is it just a "bus" for
devices to attach to and use to talk to the real devices in the system?
If so, why isn't it represented in the driver model?

thanks,

greg k-h
