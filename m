From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
 configuration
Date: Fri, 19 Dec 2014 00:45:45 +0000
Message-ID: <20141219004545.GD16239@casper.infradead.org>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD7B82@IRSMSX108.ger.corp.intel.com>
 <5492E85C.6010802@cumulusnetworks.com>
 <C4896FB061E7DE4AAC93031BDCA044B104AD9E53@IRSMSX108.ger.corp.intel.com>
 <5492EFC3.8030102@cumulusnetworks.com>
 <C4896FB061E7DE4AAC93031BDCA044B104ADA16F@IRSMSX108.ger.corp.intel.com>
 <549313B8.6050102@cumulusnetworks.com>
 <C4896FB061E7DE4AAC93031BDCA044B104ADA310@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104ADA310@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/18/14 at 06:02pm, Varlese, Marco wrote:
> Roopa, one of the comments I got from Thomas Graf on my v1 patch was that your patch and mine were supplementary ("I think Roopa's patches are supplementary. Not all switchdev users will be backed with a Linux Bridge. I therefore welcome your patches very much")... I also understood by others that the patch made sense for the same reason. I simply do not understand why these attributes (and maybe others in the future) could not be configured directly on a standard port but have to go through a bridge.

Apologies for this confusion. I take that back. I was under the
impression netdev_switch_port_bridge_setlink(), based on the "bridge"
in the function name, would derive the attributes based on capabilities
and assumption of the bridge module.

This is not the case in the latest patchset proposed so it could
indeed serve as the Netlink API for both the bridge and non bridge
case.
