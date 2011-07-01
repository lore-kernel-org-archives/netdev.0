From: Josh Lehan <linux@krellan.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Fri, 01 Jul 2011 01:39:18 -0700
Message-ID: <4E0D87B6.8090108@krellan.com>
References: <4DE44218.4070306@krellan.com> <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com> <4DE5F3E3.2080609@krellan.com> <1306949723.8149.2202.camel@tardy> <4E04A609.7010206@fandm.edu> <4E0C35F4.6050901@krellan.com> <20110630143614.GA4392@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Josh Lehan <linux@krellan.com>, janardhan.iyengar@fandm.edu,
	Janardhan Iyengar <jana.iyengar@gmail.com>, rick.jones2@hp.com,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Bryan Ford <bryan.ford@yale.edu>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server4.hostdango.com ([70.86.37.74]:43942 "EHLO
	server4.hostdango.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881Ab1GAIjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 04:39:36 -0400
In-Reply-To: <20110630143614.GA4392@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2011 07:36 AM, Neil Horman wrote:
> I'll leave the rest of this alone, since its pretty obvious that no one is going
> to break TCP for you, but just so that you're aware, The only reason you have to

That's the fundamental disconnect we've been trying to communicate: TCP
*won't break*.  None of the rules of TCP are broken, from the wire's
point of view.  The OS merely gets a richer API, from the application's
point of view, to optimize the TCP protocol implementation to serve a
wider variety of needs.

> use the 2-Wire gateway that AT&T provides is because there are no commercially
> available routers that support the uplink interface (which I expect will change

That would be good to give the customer a choice of access devices with
which to get on the network, and let the market device what is best,
instead of AT&T dictating what's allowed.  I'm getting deja vu of a
famous legal case from 27 years ago.

> eventually).  In the time being, if you want to use a different router, place
> the RG in bridge mode by selecting a host as your DMZ device.  That will assign
> the wan address to that connected device via DHCP and allow you to pass whatever
> traffic you want through it.  I use it to pass SCTP and IPv6 traffice all the
> time, works great.

Wow, that's news to me, that it allows this.

http://www.ka9q.net/Uverse/

Have the limitations in these documents been addressed?  If so, kudos to
AT&T.

Josh Lehan
