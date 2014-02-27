From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v7 net-next 2/2] tcp: switch rtt estimations to usec
 resolution
Date: Thu, 27 Feb 2014 09:57:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CC846@AcuExch.aculab.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
 <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
 <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140224155130.4c286cca@samsung-9>
 <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393309341.2316.120.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393452168.26794.8.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140226170908.5f028c88@nehalam.linuxnetplumber.net>
 <530E9315.5080606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>,
	"Yuchung Cheng" <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: 'Rick Jones' <rick.jones2@hp.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60825 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751633AbaB0J6i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 04:58:38 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21497-08 for <netdev@vger.kernel.org>;
 Thu, 27 Feb 2014 09:58:37 +0000 (GMT)
In-Reply-To: <530E9315.5080606@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones
> On 02/26/2014 05:09 PM, Stephen Hemminger wrote:
> > Since srtt is scaled by 8 and is 32 bits, This does reduce the maximum
> > possible RTT to 8 minutes or so. Which is fine, just wanted it to be
> > noted.
> 
> I have encountered some situations recently, admittedly very
> pathological, where the RTT through a VPN connection was measured in
> minutes.  I don't think it got as high as 8 minutes, but it did get as
> high as three or so.  Also mentioned only for the record.

RFC 1149 anyone :-)

I've also seen 20 minute ping responses (a long time ago).
Mind you that was a pathologically broken test senario and all sorts
of things conspired to delay the traffic.

	David
