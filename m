From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] vxlan: hide unused local variable
Date: Wed, 9 Nov 2016 17:19:48 +0100
Message-ID: <20161109171948.4bbc9615@griffin>
References: <20161107211017.857340-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        pravin shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933033AbcKIQTx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:19:53 -0500
In-Reply-To: <20161107211017.857340-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  7 Nov 2016 22:09:07 +0100, Arnd Bergmann wrote:
> A bugfix introduced a harmless warning in v4.9-rc4:
> 
> drivers/net/vxlan.c: In function 'vxlan_group_used':
> drivers/net/vxlan.c:947:21: error: unused variable 'sock6' [-Werror=unused-variable]
> 
> This hides the variable inside of the same #ifdef that is
> around its user. The extraneous initialization is removed
> at the same time, it was accidentally introduced in the
> same commit.
> 
> Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I think this should be applied instead of Pravin's patch. It fixes just
the one problem, contains the proper Fixes: tag and addresses net.git.

Acked-by: Jiri Benc <jbenc@redhat.com>
