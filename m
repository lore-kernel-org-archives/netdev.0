From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Mon, 23 Nov 2015 10:46:50 +1030
Message-ID: <20151123001650.GG2957@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151120024616.GL7136@marvin.atrad.com.au>
 <20151120224534.GA25025@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:43282 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbbKWAQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 19:16:55 -0500
Content-Disposition: inline
In-Reply-To: <20151120224534.GA25025@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 11:45:34PM +0100, Francois Romieu wrote:
> The hardware stats are not exactly clear. Is the initial Tx - Rx packet
> difference (6) at the hardware stats level expected ?

Sorry, I missed this question earlier.  When speaking to the external
device, each UDP command packet that's sent should be balanced with a
response.  However, if a UDP command is sent to a device that's not on (or
there's a typo with the address) then obviously that transmitted packet will
never be responded to.  I expect something like this could easily have
happened during the session in which I ran that test for you, so in that
case would be explainable.

I note that the difference did increase to 7 at the 1447985726.272550987 
mark.  Since this was during the test I can't quite explain that one, unless
something else on the system happened to send a UDP packet out onto that
interface which was not responded to.

Regards
  jonathan
