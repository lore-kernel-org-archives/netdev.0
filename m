From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 5 Apr 2010 13:31:55 -0600
Message-ID: <t2qfa686aa41004051231v40d7b456y90f14abfca9a06bf@mail.gmail.com>
References: <bda26c8d-00b2-411d-b4b7-ad6954b9049e@SG2EHSMHS005.ehs.local>
	<fa686aa41003171302v46738069pae51061ba83d0818@mail.gmail.com>
	<q2xfa686aa41004051110hc960e9a0sd1d5e61f7e2a5412@mail.gmail.com>
	<20100405.121647.91426186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	michal.simek@petalogix.com, jtyner@cs.ucr.edu, john.linn@xilinx.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:44700 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114Ab0DETcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:32:16 -0400
Received: by gxk9 with SMTP id 9so3132808gxk.8
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 12:32:15 -0700 (PDT)
In-Reply-To: <20100405.121647.91426186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 5, 2010 at 1:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Mon, 5 Apr 2010 12:10:51 -0600
>
>> David, are you going to pick up this patch, or would you like me to?
>
> The submitter, when asked, stated that he couldn't even get
> the driver to build on microblaze against mainline.
>
> So I marked the patch "changed requested" because being able
> to build is... you know... sort of a requirement for integration.

Heh, the current driver doesn't build on microblaze either.  However,
John, since you're removing the depends on PPC_DCR_NATIVE, can you
please respin the patch to make it depend on CONFIG_PPC and CONFIG_OF.
 Looking at it now I see that as-is it will cause collateral damage to
allmodconfig on every other architecture.

g.
