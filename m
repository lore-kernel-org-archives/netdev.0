From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r1000 driver
Date: Mon, 11 Sep 2006 00:13:39 +0200
Message-ID: <20060910221339.GB22831@electric-eye.fr.zoreil.com>
References: <20060909150457.GA5538@pp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41121 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964776AbWIJWQq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 18:16:46 -0400
To: Paolo <oopla@users.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20060909150457.GA5538@pp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paolo <oopla@users.sourceforge.net> :
[...]
> Realtek offers the GPL'd driver r1000, v1.04 at present, but seems it's not
> compatible with current 2.6.x kernel at the module param interface.

It is probably not compatible with the kernel developpers at the code
review interface either. :o)

> I've pushed Realtek src in-tree after applying the attached patches. The
> r1000 driver now compiles and WFM fine for .16.28, .17.13, .18-rc6-git3.
> 
> Hope this helps make them into .18.

Nope: upcoming 2.6.18 has been in feature freeze for ages.

The current r8169 maintainer has a patch which merges almost everything
relevant for the 8136 (almost = the device needs to be massaged through
mii-tool to correctly negotiate the link).

-- 
Ueimor
