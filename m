From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [BUG] kernel oops during bridge creation
Date: Thu, 6 Apr 2017 23:44:52 +0300
Message-ID: <20170406204452.GA24938@splinter>
References: <4d4b58e0-06e5-de5a-3305-abc739cf2ba2@svinota.eu>
 <20170406185814.GA21480@splinter>
 <adc7b0d6-68b9-6649-73fc-f5e82812f4a6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Peter V. Saveliev" <peter@svinota.eu>, netdev@vger.kernel.org,
        Ivan Vecera <ivecera@redhat.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47000 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754693AbdDFUo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:44:56 -0400
Content-Disposition: inline
In-Reply-To: <adc7b0d6-68b9-6649-73fc-f5e82812f4a6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 11:26:06PM +0300, Nikolay Aleksandrov wrote:
> Actually making br_vlan_init() idempotent might work, keep the code as-is just init the
> the vlans before the changelink() in newlink(), then the second vlan_init() inside would
> be a no-op, but it will work for the old ioctl and wouldn't require too much change.
> On the downside it will be ugly.

Yep, that can work. I'll try that tomorrow morning and let you know.

Thanks Nik!
