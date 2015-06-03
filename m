From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface link status
Date: Wed, 3 Jun 2015 11:15:55 -0700
Message-ID: <CAE4R7bD6eZGR2k-CMUhCrYhpH7sgCHCaAZ=7u1ot1j4TQGPVgA@mail.gmail.com>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33545 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933435AbbFCSQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 14:16:17 -0400
Received: by qgfa63 with SMTP id a63so7496884qgf.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 11:16:16 -0700 (PDT)
In-Reply-To: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> This feature is only enabled with the new sysctl set (default is off):
> net.core.kill_routes_on_linkdown = 1

One more thing, sorry.  This feature is typically implemented today in
user-space on a per-interface basis.  The example I'm thinking of is
Quagga's "link-detect" directive which goes on an interface.  Should
this be a bool on each interface in systcl?  That would let user not
enable on selected interfaces.
