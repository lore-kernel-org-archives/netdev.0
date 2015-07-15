From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 15:00:31 -0400
Message-ID: <20150715190030.GA504@gospo.home.greyhouse.net>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
 <CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com>
 <CACcJQnRb89XcEy7c42aNYrvG7SHAU7Lak_+Hj2rWyVeSqpzt6A@mail.gmail.com>
 <CAE4R7bB6N-auEk8hZhVv4OxVFtPTZ63d78TF376pxPcn=mnE9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35238 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbbGOTAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 15:00:40 -0400
Received: by qkbp125 with SMTP id p125so35054353qkb.2
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 12:00:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bB6N-auEk8hZhVv4OxVFtPTZ63d78TF376pxPcn=mnE9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 11:29:55AM -0700, Scott Feldman wrote:
[...]
> 
> On the iproute2 part, do we expect users to manually toggle this flag
> from the cmdline?  Seems kind of weird to walk up to a box and say "ip
> link set dev DEV protodown on".  Isn't this more intended for external
> agents (i.e. MLAG) to toggle?  I guess if there is a netlink attr for
> the flag, there should be a user-interface.  But it seems like it'll
> be a source of confusion for 99.999% of the users out there that
> wonder what this knob does.

I would want to have it in iproute2 the event that I killed an app that
set this flag for me.  This would allow me to clear the bit and use the
interface as I pleased.  I would not want to have to reboot just to use
my device again.
