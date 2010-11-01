From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] OF device tree: Move of_get_mac_address() to a common
 source file.
Date: Mon, 1 Nov 2010 10:46:03 -0500
Message-ID: <AANLkTimp-AFN5T3z9o6X9qM-GQXSU5vinf+Lqu_jUmJj@mail.gmail.com>
References: <1288130833-16421-1-git-send-email-ddaney@caviumnetworks.com> <20101101051734.GB17587@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:34235 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831Ab0KAPqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 11:46:36 -0400
Received: by iwn10 with SMTP id 10so7169324iwn.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 08:46:36 -0700 (PDT)
In-Reply-To: <20101101051734.GB17587@angua.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 1, 2010 at 12:17 AM, Grant Likely <grant.likely@secretlab.ca> wrote:

> Applied, thanks; but made some changes to protect this code because it
> does not work on little endian (it can be fixed in a separate patch)

I'm confused.  How does of_get_mac_address() not work on little-endian?

-- 
Timur Tabi
Linux kernel developer at Freescale
