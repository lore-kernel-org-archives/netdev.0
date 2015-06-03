From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface link status
Date: Wed, 3 Jun 2015 12:03:53 -0700
Message-ID: <CAE4R7bDLgHYzWC=m-R73psbyLwZh0fvL_diFyW3g1DF8eve1sw@mail.gmail.com>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bD6eZGR2k-CMUhCrYhpH7sgCHCaAZ=7u1ot1j4TQGPVgA@mail.gmail.com> <20150603182718.GK588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:34788 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbbFCTEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:04:15 -0400
Received: by qcej9 with SMTP id j9so8421073qce.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:04:14 -0700 (PDT)
In-Reply-To: <20150603182718.GK588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 3, 2015 at 11:27 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Wed, Jun 03, 2015 at 11:15:55AM -0700, Scott Feldman wrote:
>> On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
>> <gospo@cumulusnetworks.com> wrote:
>> > This feature is only enabled with the new sysctl set (default is off):
>> > net.core.kill_routes_on_linkdown = 1
>>
>> One more thing, sorry.  This feature is typically implemented today in
>> user-space on a per-interface basis.  The example I'm thinking of is
>> Quagga's "link-detect" directive which goes on an interface.  Should
>> this be a bool on each interface in systcl?  That would let user not
>> enable on selected interfaces.
> That would not be my preference.
>
> I'm willing to investigate the per-namespace support if Hannes would
> like and add switchdev support for v2, but would prefer this not become
> that granular.


Is there a reason?  Seems you moving a feature from user space to the
kernel, so I'm curious why you wouldn't want to mimic functionality
that's available today.

I like the patch/feature, BTW.  Thanks for doing this.

-scott
