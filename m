From: "Guthrie, Jeremy" <jeremy.guthrie@berbee.com>
Subject: RE: Linux Routing Performance Update
Date: Sat, 29 Jan 2005 16:21:39 -0600
Message-ID: <D078DAD578D48A46A67AB71E6D2324940FC7DB@CTG-MSNEXC01.staff.berbee.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Florian Weimer" <fw@deneb.enyo.de>,
        "Glen Turner" <glen.turner@aarnet.edu.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----Original Message-----
From: netdev-bounce@oss.sgi.com on behalf of Florian Weimer
Sent: Sat 1/29/2005 12:50 PM
To: Glen Turner
Cc: Robert Olsson; netdev@oss.sgi.com
Subject: Re: Linux Routing Performance Update
 
* Glen Turner:

>> Finally time for some more testing with a somewhat upgraded equipment.
>
> Thanks very much for the interesting results.

Indeed.

> I'm sure other network engineers have experienced software routers where
> the pps has dramatically slowed down upon reasonable ACLs and queuing
> (Cisco 7500, etc),

Cisco 7500 with proper configuration would do quite well in this test,
too, even with ACLs.  Only if you have more than a few thousand new
flows per second, things start to look rather bleak.  (Forwarding
decisions are performed once per flow on this platform.)
-----------

Depends if you are using standard route caching or Cisco Express Forwarding.  The 7500s should support dCEF if memory strikes me correctly.  In any case, when CEF is available it should be used.  Comparing any Cisco router w/o CEF or MLS wouldn't exactly be a fair comparison.  MLS will care about new flows but CEF will not.

> so some results with netfilter and tc running would be appreciated,
> as would tests for any packet re-ordering in output flows.

I'd also like to see tests with random source/destination
combinations, just to keep things in perspective. 8-)
