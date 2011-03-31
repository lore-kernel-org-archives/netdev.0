From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH RESEND] net: convert xen-netfront to hw_features
Date: Thu, 31 Mar 2011 13:37:27 +0200
Message-ID: <20110331113727.GA19215@rere.qmqm.pl>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl> <1301570010.27123.172.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50176 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056Ab1CaLhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 07:37:31 -0400
Content-Disposition: inline
In-Reply-To: <1301570010.27123.172.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2011 at 12:13:30PM +0100, Ian Campbell wrote:
> On Thu, 2011-03-31 at 12:01 +0100, Micha=B3 Miros=B3aw wrote:
> > Not tested in any way. The original code for offload setting seems =
broken
> > as it resets the features on every netback reconnect.
> Thanks, I've got a pending TODO item to test this and propagate simil=
ar
> changes to netback. I hope to get to it soon...
>=20
> Is this urgent (for 2.6.39) IYHO? I think it's been broken this way f=
or
> a long time now...

This probably affects only people who are using suspending VM's to disk=
 or
[live] migration. The bug is hard to notice if you're not looking for i=
t.
I only noticed it after trying to change the code.

Best Regards,
Micha=B3 Miros=B3aw
