From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH 1/3] lib/vsprintf.c: Add %pU - ptr to a UUID/GUID
Date: Sun, 27 Sep 2009 12:45:33 +0200
Message-ID: <200909271245.34000.ioe-lkml@rameria.de>
References: <cover.1254030722.git.joe@perches.com> <1507728e0ea3deafa71c481d508a6e9765c92221.1254030722.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay04.ispgateway.de ([80.67.31.27]:38628 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790AbZI0Ky6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2009 06:54:58 -0400
In-Reply-To: <1507728e0ea3deafa71c481d508a6e9765c92221.1254030722.git.joe@perches.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Sunday 27 September 2009, Joe Perches wrote:
> UUID/GUIDs are somewhat common in kernel source.
> 
> Standardize the printed style of UUID/GUIDs by using
> another extension to %p.
> 
> %pU:    01020304:0506:0708:090a:0b0c0d0e0f10
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ here
> %pUr:   04030201:0605:0807:0a09:0b0c0d0e0f10
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ and here

Code does "01020304-0506-0708-090a-0b0c0d0e0f10".
This is not, what commit promises. Please change the commit message!

Best Regards

Ingo Oeser
