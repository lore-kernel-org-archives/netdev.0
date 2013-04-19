From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 15:58:59 -0400 (EDT)
Message-ID: <20130419.155859.1092595631804890737.davem@davemloft.net>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net>
	<20130419194537.GA1633@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab3DST7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 15:59:01 -0400
In-Reply-To: <20130419194537.GA1633@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 19 Apr 2013 12:45:37 -0700

> On Fri, Apr 19, 2013 at 12:06:51PM -0700, Stephen Hemminger wrote:
>> Netmap is a framework for packet generation and capture from user
>> space. It allows for efficient packet handling (up to line rate on
>> 10Gb) with minimum system load.  For more info see:
>> 	http://info.iet.unipi.it/~luigi/netmap/

So are you saying that people can't get line rate today?

Even the the suricata folks are doing deep packet inspection at line
rate using AF_PACKET fanouts just fine.  That means they aren't just
grabbing packets, they are actually processing them and making
stateful decisions based upon the packet's contents.

That means that capture is cheap enough already that they have all
the compute left over that they need.

The existing mechanisms also have the huge advantage that they are
already implemented, require zero driver specific changes, and are
already starting to be deployed to end users.

Given that and how incredibly gross this code is right now, the only
reaction I can have is "meh".

If you are going to propose something, please show a real and genuine
need.
