From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc-tbf.8: Add parameter range to man page.
Date: Mon, 20 Aug 2012 10:58:03 -0700
Message-ID: <20120820105803.2ce45a2a@nehalam.linuxnetplumber.net>
References: <1344306632-15288-1-git-send-email-lw@cn.fujitsu.com>
	<20120813083015.27b66cd7@nehalam.linuxnetplumber.net>
	<5031DADC.6060509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51370 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198Ab2HTR6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 13:58:19 -0400
In-Reply-To: <5031DADC.6060509@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Not very clear with "the generic documentation about qdisc parameters
> which already exists on 'tc-qdisc' man page", is there a separate man page
> that describe qdisc parameters?
> 
> I'm reading the iproute2 and kernel code which related to TC and record the
> value range for each parameter, I think that would be helpful for somebody
> else.
> 

Rather than putting range on each parameter on every sub-page of tc man
page. Why not put something in tc.8 under UNITS.

The following implies everything is floating-point which it isn't:

UNITS
       All parameters accept a floating point number, possibly followed  by  a
       unit.

I would like this section broken down to cover all the generic types
  PARAMETERS
     RATES
     TIMES
     SIZES
     VALUES

Also needs to explain IEC units here.
