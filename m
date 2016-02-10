From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob
Date: Wed, 10 Feb 2016 10:16:27 +0100
Message-ID: <DF83416F-314C-4F27-A649-DD6574A83AE7@gmail.com>
References: <56ABE3A8.4010602@gmail.com> <1455015744.3592.46.camel@intel.com> <20160209115921.GE18781@lunn.ch>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36025 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbcBJJQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 04:16:30 -0500
Received: by mail-wm0-f44.google.com with SMTP id p63so18635831wmp.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 01:16:29 -0800 (PST)
In-Reply-To: <20160209115921.GE18781@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 9, 2016, at 12:59, Andrew Lunn <andrew@lunn.ch> wrote:

>>> +       dn = of_find_compatible_node(NULL, NULL, "intel,i211");
> 
> Humm, NULL, NULL. That means find the first node anywhere in the
> device tree which matches. This is not going to work too well when you
> have multiple i211s.
> 
> There is a way so specify a DT node is attached to a specific PCIe
> bus/slot. I think you should search only there, so solving the
> multiple device issue.
> 

Good point. Will specify the current PCIe node.
