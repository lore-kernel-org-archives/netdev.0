From: "Varlese, Marco" <marco.varlese@intel.com>
Subject: RE: [RFC PATCH net-next 1/1] net: Support for switch port
 configuration
Date: Mon, 15 Dec 2014 14:29:12 +0000
Message-ID: <C4896FB061E7DE4AAC93031BDCA044B104AC5DCF@IRSMSX108.ger.corp.intel.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
 <20141210165018.GG1863@nanopsycho.orion> <54887CF7.70708@gmail.com>
 <C4896FB061E7DE4AAC93031BDCA044B104AC3914@IRSMSX108.ger.corp.intel.com>
 <20141215140749.GB21952@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65467 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753176AbaLOO3o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 09:29:44 -0500
In-Reply-To: <20141215140749.GB21952@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas Graf
> Sent: Monday, December 15, 2014 2:08 PM
> To: Varlese, Marco
> Cc: John Fastabend; Jiri Pirko; netdev@vger.kernel.org;
> stephen@networkplumber.org; Fastabend, John R;
> roopa@cumulusnetworks.com; sfeldma@gmail.com; linux-
> kernel@vger.kernel.org
> Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port
> configuration
> 
> On 12/11/14 at 09:59am, Varlese, Marco wrote:
> > An example of attributes are:
> > * enabling/disabling of learning of source addresses on a given port
> > (you can imagine the attribute called LEARNING for example);
> > * internal loopback control (i.e. LOOPBACK) which will control how the
> > flow of traffic behaves from the switch fabric towards an egress port;
> > * flooding for broadcast/multicast/unicast type of packets (i.e.
> > BFLOODING, MFLOODING, UFLOODING);
> 
> All of these are highly generic and should *not* be passed through from user
> space to the driver directly but rather be properly abstracted as Roopa
> proposed. The value of this API is abstraction.
How would you let the user enable/disable features then? For instance, how would the user enable/disable flooding for broadcast packets (BFLOODING) on a given port? What I was proposing is to have a list of attributes (to be added in if_link.h) which can be tuned by the user using a tool like iproute2. What do you propose? 
I think I have seen Roopa posting his updated ndo patch and getting some feedback by few people already and as long as I will be able to accomplish the use case described here I am happy with his way.

> If we introduce per device attributes for generic functions we lose large
> portions of the value gained.
> You mentioned you have additional attributes in mind, maybe you can give a
> few examples which are not generic, i.e. do not apply to multiple vendors.
I do not have an example right now of a vendor specific attribute but I was just saying that might happen (i.e. someone will have a feature not implemented by others?).
