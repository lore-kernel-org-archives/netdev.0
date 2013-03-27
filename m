From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Is there a preferred way to get the VXLAN port number?
Date: Wed, 27 Mar 2013 10:52:54 -0700
Message-ID: <20130327105254.2e10de02@nehalam.linuxnetplumber.net>
References: <51521B05.6060401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>, pshelar@nicira.com,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38811 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725Ab3C0RxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:53:06 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb10so694233pad.11
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 10:53:06 -0700 (PDT)
In-Reply-To: <51521B05.6060401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Mar 2013 15:02:45 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> I was wondering if someone would happen to know if there is already a
> preferred way to get the VXLAN port number for things such as
> configuring a device to recognize a VXLAN frame on receive for parsing
> purposes?
> 
> I just wanted to check to make sure I hadn't missed something before
> submitting a patch that would export a simple function for supplying the
> vxlan_port value.
> 
> Thanks,
> 
> Alex
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

There are two views of the world. One view is that the UDP port number
should be a fixed assigned number by IANA, and since VXLAN looks exactly
like Cisco LISP, that is what most people use. Others like DOVE seem
to want to use lots of values.
