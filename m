From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 rxhash
Date: Thu, 6 Oct 2011 09:52:54 -0700
Message-ID: <1317919974.8939.5.camel@HP1>
References: <4E8D7B85.7060702@fox-it.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jasper Spaans" <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3695 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965078Ab1JFRCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 13:02:33 -0400
In-Reply-To: <4E8D7B85.7060702@fox-it.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2011-10-06 at 02:57 -0700, Jasper Spaans wrote:
> The data I'm processing consists of (almost 100% tcp) traffic between an
> ssl-offloader and a cluster of webservers, so the range of mac-addresses
> is rather limited. This ssl-offloader does preserve the IP-address and
> tcp ports of the clients, so if the rxhash is based on that data, it
> should be distributed evenly.
> 
> Is there anything I can do about this?
> 

Can you send me a small tcpdump/wireshark trace of the incoming packets?
I just need to see the tuple values in the packet headers.  Thanks.
