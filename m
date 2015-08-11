From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] documentation: bring vxlan documentation more
 up-to-date
Date: Tue, 11 Aug 2015 15:09:57 -0700
Message-ID: <20150811150957.78de9c33@urahara>
References: <20150811204716.79B2C29004D1@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: raj@tardy.usa.hp.com (Rick Jones)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35167 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbbHKWJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 18:09:55 -0400
Received: by pacgr6 with SMTP id gr6so59395348pac.2
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 15:09:54 -0700 (PDT)
In-Reply-To: <20150811204716.79B2C29004D1@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Aug 2015 13:47:16 -0700 (PDT)
raj@tardy.usa.hp.com (Rick Jones) wrote:

> +  # ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth1
> +
> +This creates a new device named vxlan0.  The device uses the
> +multicast group 239.1.1.1 over eth1 to handle traffic for which there
> +is no entry is in the forwarding table.  The Linux implementation of
> +VXLAN pre-dates the IANA's selection of a standard destination port
> +number and uses the Linux-selected value by default to maintain
> +backwards compatibility.  If you wish to use the IANA-assigned
> +destination port number of 4789 you can add "dstport 4789" to the
> +command line above.

This example should be changed to use "dstport 4789".
Almost anyone reading the documentation will want to use the IANA value.

Note: ip command will give a noisy warning if dstport is not set.
