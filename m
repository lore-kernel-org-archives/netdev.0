From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Thu, 15 Jul 2010 23:12:49 +0200
Message-ID: <20100715211249.GA7278@electric-eye.fr.zoreil.com>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-137-244-105.adslgp.cegetel.net ([88.137.244.105]:44320 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934743Ab0GOVMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 17:12:55 -0400
Content-Disposition: inline
In-Reply-To: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang <junchangwang@gmail.com> :
[...]
> 2) Why does r8169 bias towards the first approach even if it support both ?

It is a simple, straightforward fix against a 8169 hardware bug.

See commit c0cd884af045338476b8e69a61fceb3f34ff22f1.

-- 
Ueimor
