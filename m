From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Repeatable r8169 kernel oops testcase
Date: Mon, 1 Dec 2008 23:43:16 +0100
Message-ID: <20081201224316.GB1024@electric-eye.fr.zoreil.com>
References: <49336B0A.6000000@sneakemail.com> <1228122667.3160.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jcliburn@gmail.com, netdev@vger.kernel.org
To: Dale Ogilvie <k1qeelx02@sneakemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52500 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751847AbYLAWnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:43:33 -0500
Content-Disposition: inline
In-Reply-To: <1228122667.3160.19.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dale Ogilvie <k1qeelx02@sneakemail.com> :
[...]
> None of these changes made any difference. Networking is dead until the
> r8169 module is unloaded and reloaded. Also, while the network is up but
> "dead", mouse input is erratic. Moving the mouse is not smooth at all.
> Something is severely wrong while the r8169 module is in this state.

Is it possible for you to log 'mii-tool -v -v eth0' output:
- before the watchdog fires
- after it fires and before the module removal
- after the module removal / insertion, when everything seems right

-- 
Ueimor
