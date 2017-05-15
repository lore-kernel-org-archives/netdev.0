From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: no address filtering on RNDIS
Date: Mon, 15 May 2017 14:20:20 +0200
Message-ID: <87efvqia63.fsf@miraculix.mork.no>
References: <20170515115853.32688-1-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34185 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750935AbdEOMUk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 08:20:40 -0400
In-Reply-To: <20170515115853.32688-1-oneukum@suse.com> (Oliver Neukum's
        message of "Mon, 15 May 2017 13:58:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:

> RNDIS does not do multicast filtering and the commands crash a few device=
s.
> Make it conditional.


Strange.  I thought we already discussed this when the filter reset
request was initially added 3 years ago.  Ref
https://patchwork.ozlabs.org/patch/374137/



Bj=C3=B8rn
