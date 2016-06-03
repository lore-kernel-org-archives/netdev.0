From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 00/17] New DSA bind, switches as devices
Date: Fri, 03 Jun 2016 16:38:34 -0400
Message-ID: <8760tqj9dh.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55143 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422688AbcFCUii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 16:38:38 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The interesting patches here are the last three. They implement a new
> binding for DSA, which removes a few limitations of the current DSA
> binding. In particular, it allows switches to be true Linux devices.
> These devices can be on any type of bus, unlike the old DSA binding
> which assumes MDIO. See the commit log for more details. The second to
> last patch modifies an existing boards device tree to use the new
> binding, giving a good example of how switches can be true MDIO
> devices. The last patch documents the new binding.
>
> I know both John Crispin and Bryan Whitehead are interesting in
> implementing DSA drivers, hence i have CC: you. Comments welcome.
>
> Thanks go to Florian and Vivien for reviewing, testing and bug fixing
> these patches.
>
> Since RFC:
>
> * Split the mv88e6xxx MDIO refactor into a rename patch and a refactor
>   patch.
> * Extend commit message with comment about wrong of_node_put()
> * Fix destroy of cpu and dsa ports.
> * Rename _DSA_TAG_LAST to DSA_TAG_LAST and add a comment.

This patchset works fine on a 3-mv88e6xxx setup with the old bindings.

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
