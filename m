From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 8 Aug 2011 11:01:57 -0700
Message-ID: <CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<20110808084016.063a0699@nehalam.ftrdhcpuser.net>
	<CA+mtBx_vgsH+uHLi6p80E8CEhU7SHXY=Fw1Z-W2OFWy44LP-ig@mail.gmail.com>
	<20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:1848 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab1HHSCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 14:02:00 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p78I1xim004255
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 11:01:59 -0700
Received: from gwj15 (gwj15.prod.google.com [10.200.10.15])
	by wpaz29.hot.corp.google.com with ESMTP id p78I0vMJ018110
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 11:01:58 -0700
Received: by gwj15 with SMTP id 15so3576209gwj.39
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 11:01:58 -0700 (PDT)
In-Reply-To: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since transmit completion means calling dev_kfree_skb() why not account
> there? You could add some info to netdev if necessary to get compile
> the statistics.
>
The algorithm depends on knowing the total number of packets competed
in a single execution of transmit completion (epic based).  We only
want to recalculate the limits once per completion, which happens when
the completion function is called.

> I just hate driver api complexity growth.
>
>
