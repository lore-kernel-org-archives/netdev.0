From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 22:13:44 -0400
Message-ID: <42A8F758.2060008@pobox.com>
References: <200506090909.55889.vda@ilport.com.ua>	<20050608.231657.59660080.davem@davemloft.net>	<20050609104205.GD3169@elf.ucw.cz> <20050609.125324.88476545.davem@davemloft.net> <42A8AE2A.4080104@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, pavel@ucw.cz,
	vda@ilport.com.ua, abonilla@linuxwireless.org, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261435AbVFJCNz@vger.kernel.org>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <42A8AE2A.4080104@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> I don't know if all the distributions have moved away from this model. 
> If they have and the devices are brought up regardless of link, then
> going back to delaying radio initialization until the open() is called
> is workable. 


When the interface is not up, we ideally want the device to be as 
passive as possible.

Most net drivers shut down as much as possible at dev->close() time, and 
it would really be good if wireless drivers followed suit.

	Jeff
