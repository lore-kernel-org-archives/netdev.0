From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2/m_ipt fix, opts was not set properly
Date: Wed, 06 Aug 2008 06:42:30 -0400
Message-ID: <1218019350.4755.30.camel@localhost>
References: <200808052224.36773.denys@visp.net.lb>
	 <1218016372.4755.15.camel@localhost> <200808061306.39846.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:33572 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbYHFKme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:42:34 -0400
Received: by an-out-0708.google.com with SMTP id d40so495064and.103
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 03:42:34 -0700 (PDT)
In-Reply-To: <200808061306.39846.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 13:06 +0300, Denys Fedoryshchenko wrote:

> Make attention - before static void free_opts(struct option *opts) was 
> shadowing global variable with same name *opts, after this patch - it will 
> not shadow anymore.

Sorry Denys, unless my memory has lost the C scoping rules, i dont think
the shadowing you describe above is accurate. Let me take a closer look.

[BTW, this code was all copied from iptables - so if this bug exists
here, it likely still exists in iptables. The xtables changes will make
this code a lot more maintainable].

cheers,
jamal

