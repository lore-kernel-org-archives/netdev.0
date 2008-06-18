From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: data received but not detected
Date: Wed, 18 Jun 2008 10:28:58 +0400
Message-ID: <20080618062857.GA3598@2ka.mipt.ru>
References: <1213740538.5771.192.camel@localhost.localdomain> <48583B37.5070708@candelatech.com> <1213743506.5771.220.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51059 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbYFRG3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 02:29:00 -0400
Content-Disposition: inline
In-Reply-To: <1213743506.5771.220.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jun 17, 2008 at 05:58:26PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> I understand that there is no guarantee of anything with UDP, but it
> seems to me that if there is a packet in the buffer (it shows up after
> another packet comes in behind it) the system should know about it,
> right?

Did you run wireshark on receiver or sender?
Check MIB stats if packet was dropped because of low mem or incorrect
checksumm or some other problematic fields in UDP header. Sending part
can see it perfectly correct, which will not be the issue on the
receiver. If packet was delivered to receiving host, udp input path is
rather simple so there are no places which can race with something and
thus lost the packet.

-- 
	Evgeniy Polyakov
