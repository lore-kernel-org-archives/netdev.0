From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]ethtool.c:fix buffer overflow when devname is too long
Date: Wed, 30 Aug 2006 07:30:00 -0400
Message-ID: <44F576B8.9010000@garzik.org>
References: <20060830105243.GA17772@ldy-gentoo.cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:24232 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750823AbWH3LaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 07:30:03 -0400
To: wangzyu@cn.ibm.com
In-Reply-To: <20060830105243.GA17772@ldy-gentoo.cn.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wangzyu@cn.ibm.com wrote:
> As the length of field ifr_name of struct ifreq is IFNAMSIZ(16) in header file /usr/include/net/if.h. 
> It will result in buffer overflow when devname is too long. Modified strcpy to strncpy for only 
> copying IFNAMSIZ bytes into struct ifreq. Also, by adding a section into parse_cmdline to detect 
> if the length of devname is invalid.
> 
> Signed-off-by: Zhao Yu Wang <wangzyu@cn.ibm.com>

There's already a patch checked into ethtool.git for this...

	Jeff



