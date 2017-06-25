From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add netlink_ext_ack support to
 rtnl_link_ops
Date: Sun, 25 Jun 2017 11:50:12 -0400 (EDT)
Message-ID: <20170625.115012.1229577774043704298.davem@davemloft.net>
References: <01256ebba091f2108ebeff43e61305bb533067d4.1498303258.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, dmitry.tarnyagin@lockless.no,
        wg@grandegger.com, mkl@pengutronix.de, pablo@netfilter.org,
        laforge@gnumonks.org, paulus@samba.org, jiri@resnulli.us,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        stephen@networkplumber.org, arvid.brodin@alten.se,
        alex.aring@gmail.com, stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, osmocom-net-gprs@lists.osmocom.org,
        linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
To: mschiffer@universe-factory.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdFYPuS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 11:50:18 -0400
In-Reply-To: <01256ebba091f2108ebeff43e61305bb533067d4.1498303258.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Sat, 24 Jun 2017 13:35:17 +0200

> The following functions are extended with a netlink_ext_ack argument to
> allow extended error reporting:
> 
> * validate
> * newlink
> * changelink
> * slave_validate
> * slave_changelink
> 
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>

Like David Ahern, I think you should split this patch up.

Thanks.
