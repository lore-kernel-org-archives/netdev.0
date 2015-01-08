From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] vxlan: Allow for VXLAN extensions to be implemented
Date: Thu, 8 Jan 2015 00:14:01 +0000
Message-ID: <20150108001401.GG21149@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <7c5e8240263a22a69042c45a632c9940e5ae1062.1420594925.git.tgraf@suug.ch>
 <CA+mtBx_mp1mf_HPp5u9wDfgeOc8pt26Mf1VHFZTAqDhTdZe7cw@mail.gmail.com>
 <20150107102740.GM21820@casper.infradead.org>
 <CAEP_g=_Xr=6nVoeVT8dgRZoM0bNXDiiua5GrjweZ1GaT1ixhZg@mail.gmail.com>
 <20150107232412.GD21149@casper.infradead.org>
 <CA+mtBx8HDc1OfsuED8afUnTdf562RAyU37tVeKk0ndAm5wMWfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38384 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753708AbbAHAOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 19:14:04 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx8HDc1OfsuED8afUnTdf562RAyU37tVeKk0ndAm5wMWfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 04:02pm, Tom Herbert wrote:
> Do you know how could GPE work with GBP they want to use the same bits
> in header for data? Seems like these are mutually exclusive
> extensions. RCO should be fine with either :-)

Yes, GBP and GPE are mutually exclusive extensions. Although
GPE would allow to define an intermediate header for additional
metadata, f.e. encoded as GUE or Geneve options.
