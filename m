From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port
 configuration
Date: Mon, 15 Dec 2014 14:07:49 +0000
Message-ID: <20141215140749.GB21952@casper.infradead.org>
References: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
 <20141210165018.GG1863@nanopsycho.orion>
 <54887CF7.70708@gmail.com>
 <C4896FB061E7DE4AAC93031BDCA044B104AC3914@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104AC3914@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/14 at 09:59am, Varlese, Marco wrote:
> An example of attributes are:
> * enabling/disabling of learning of source addresses on a given port (you can imagine the attribute called LEARNING for example);
> * internal loopback control (i.e. LOOPBACK) which will control how the flow of traffic behaves from the switch fabric towards an egress port;
> * flooding for broadcast/multicast/unicast type of packets (i.e. BFLOODING, MFLOODING, UFLOODING);

All of these are highly generic and should *not* be passed through
from user space to the driver directly but rather be properly
abstracted as Roopa proposed. The value of this API is abstraction.
If we introduce per device attributes for generic functions we lose
large portions of the value gained.

You mentioned you have additional attributes in mind, maybe you can
give a few examples which are not generic, i.e. do not apply to
multiple vendors.
