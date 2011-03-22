From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] TCP CUBIC Hystart fixes
Date: Tue, 22 Mar 2011 05:05:06 -0700 (PDT)
Message-ID: <20110322.050506.226754526.davem@davemloft.net>
References: <20110314175211.788224699@vyatta.com>
	<20110322113542.GB21254@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: lucas.nussbaum@loria.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751641Ab1CVME2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 08:04:28 -0400
In-Reply-To: <20110322113542.GB21254@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Date: Tue, 22 Mar 2011 12:35:42 +0100

> On 14/03/11 at 10:52 -0700, Stephen Hemminger wrote:
>> This is the merge of my patches and recent update Sangtae.
>> It addresses the problems reported by Lucas Nussbaum that Hystart causes
>> poor startup performance over links with lots of buffering.
> 
> What do you plan to do regarding stable kernels? We should probably
> either push that patch serie, or disable hystart if HZ < 1000.

I think once the patch series gets some soaking time in Linus's tree
we can send it over to -stable.
