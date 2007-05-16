From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 12:10:44 -0700
Message-ID: <464B5734.2070904@hp.com>
References: <20070516083120.23311.3272.stgit@localhost.localdomain>	<464B2426.9060502@garzik.org> <464B504B.5090007@hp.com> <464B55E1.8040501@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Auke Kok <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:46422 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758455AbXEPTKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 15:10:48 -0400
In-Reply-To: <464B55E1.8040501@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

H. Peter Anvin wrote:
> Rick Jones wrote:
> 
>>Some more of my paranoid questions :)
>>
>>So, if a driver tries to enable MSI and that is unsuccessful (I'll try
>>to avoid using the possibly loaded term "fails") shouldn't that show-up
>>_somewhere_?
> 
> 
> It already does -- in /proc/interrupts.

But that is rather incidental isn't it?  Would some sort of system health 
monitor be likely to be checking that for interrupt flavors?  And just looking 
at /proc/interrupts, while it tells you what sort of interrupt is being used, it 
doesn't (IIRC) say anything about what sort of interrupt the driver _tried_ to use.

rick jones
