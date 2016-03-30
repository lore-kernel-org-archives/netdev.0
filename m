From: Patrick Uiterwijk <patrick@puiterwijk.org>
Subject: Re: [PATCH net-next v3 1/2] net: dsa: mv88e6xxx: Introduce _mv88e6xxx_phy_page_{read,write}
Date: Wed, 30 Mar 2016 15:21:01 +0000
Message-ID: <CAJweMdZLM63dxEyByvF4vxtYfqtK39mw7TC1mbAHX=JcpRk97A@mail.gmail.com>
References: <1459301981-26535-1-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>
To: Guenter Roeck <linux@roeck-us.net>, davem@davemloft.net,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:33926 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbcC3PVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 11:21:03 -0400
Received: by mail-vk0-f41.google.com with SMTP id e185so65271259vkb.1
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 08:21:02 -0700 (PDT)
In-Reply-To: <1459301981-26535-1-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Could this patch and the patch 2/2 v3 "net: dsa: mv88e6xxx: Clear the
PDOWN bit on setup" be put
on net, since this fixes a bug with the clearfog, which was introduced in v4.5?

Thanks,
Patrick

On Wed, Mar 30, 2016 at 1:39 AM, Patrick Uiterwijk
<patrick@puiterwijk.org> wrote:
> Add versions of the phy_page_read and _write functions to
> be used in a context where the SMI mutex is held.
>
> Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>
> ---
