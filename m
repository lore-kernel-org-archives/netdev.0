From: Ben Greear <greearb@candelatech.com>
Subject: af_packet.c bug?
Date: Mon, 28 Mar 2005 11:19:48 -0800
Message-ID: <424858D4.8060604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


What is the '13' doing here?  Maybe it should be IFNAMSIZ?

	/*
	 *	Find the device first to size check it
	 */

	saddr->spkt_device[13] = 0;
	dev = dev_get_by_name(saddr->spkt_device);
	err = -ENODEV;
	if (dev == NULL)
		goto out_unlock;



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
