From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch iproute2 1/2] devlink: write usage help messages to
 stderr
Date: Tue, 9 Aug 2016 10:34:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F50D107@AcuExch.aculab.com>
References: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
	<20160723094659.06921b95@xeon-e3>	<20160808071921.GA1944@nanopsycho.orion>
 <20160808085654.764550e2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"nogahf@mellanox.com" <nogahf@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:59869 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbcHIKgG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:36:06 -0400
In-Reply-To: <20160808085654.764550e2@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger
> Sent: 08 August 2016 16:57
> To: Jiri Pirko
...
> > >> In order to not confuse reader, write help messages into stderr.
> > >>
> > >> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > >
> > >This does make devlink consistent with other parts of iproute2.
> > >But the most common coding standards, back to Unix, and GNU are
> > >that help messages should go to stdout so that:
> > >  $ ip -h | more
> > >would work as expected.
> >
> > The thing is I wanted to make stdout only for json. Putting non-json
> > help out there does not look correct to me. Is it?
> >
> 
> I applied both of these patches, just wanted to mention that iproute2 is not
> following the GNU convention. At this point, it really doesn't matter, there
> are arguments to be made for both behaviors.

If you output help in response to an invalid option (eg) 'ip -?' then you
need to write it to stderr since it is part of the error message.
OTOH if help is explicitly requested 'ip -h' then stdout would be ok.

Nothing wrong with typing 'ip -h 2>&1 | pg' though.

	David
