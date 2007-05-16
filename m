From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 11:41:15 -0700
Message-ID: <464B504B.5090007@hp.com>
References: <20070516083120.23311.3272.stgit@localhost.localdomain> <464B2426.9060502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, hpa@zytor.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:42504 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394AbXEPSlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 14:41:21 -0400
In-Reply-To: <464B2426.9060502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more of my paranoid questions :)

So, if a driver tries to enable MSI and that is unsuccessful (I'll try to avoid 
using the possibly loaded term "fails") shouldn't that show-up _somewhere_? 
Just how "normal" is an attempt to enable MSI not succeding going to remain over 
time and aren't there times when it does indeed mean that someone should be 
looking into it?

rick jones
