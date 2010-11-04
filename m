From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] inet_diag: Make sure we actually run the same
 bytecode we audited.
Date: Thu, 04 Nov 2010 12:26:50 -0700 (PDT)
Message-ID: <20101104.122650.115919734.davem@davemloft.net>
References: <1288838141-17871-1-git-send-email-nelhage@ksplice.com>
	<1288838141-17871-2-git-send-email-nelhage@ksplice.com>
	<20101104132802.GA2904@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nelhage@ksplice.com, netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56779
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277Ab0KDT00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 15:26:26 -0400
In-Reply-To: <20101104132802.GA2904@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Thu, 4 Nov 2010 09:28:02 -0400

> On Wed, Nov 03, 2010 at 10:35:41PM -0400, Nelson Elhage wrote:
>> We were using nlmsg_find_attr() to look up the bytecode by attribute when
>> auditing, but then just using the first attribute when actually running
>> bytecode. So, if we received a message with two attribute elements, where only
>> the second had type INET_DIAG_REQ_BYTECODE, we would validate and run different
>> bytecode strings.
>> 
>> Fix this by consistently using nlmsg_find_attr everywhere.
>> 
>> Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
> 
> Both patches look good.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied.
