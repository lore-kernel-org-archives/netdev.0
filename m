From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH 2/2] inet_diag: Make sure we actually run the same
 bytecode we audited.
Date: Thu, 4 Nov 2010 09:28:02 -0400
Message-ID: <20101104132802.GA2904@canuck.infradead.org>
References: <1288838141-17871-1-git-send-email-nelhage@ksplice.com>
 <1288838141-17871-2-git-send-email-nelhage@ksplice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nelson Elhage <nelhage@ksplice.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:39985 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab0KDN2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 09:28:04 -0400
Content-Disposition: inline
In-Reply-To: <1288838141-17871-2-git-send-email-nelhage@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 10:35:41PM -0400, Nelson Elhage wrote:
> We were using nlmsg_find_attr() to look up the bytecode by attribute when
> auditing, but then just using the first attribute when actually running
> bytecode. So, if we received a message with two attribute elements, where only
> the second had type INET_DIAG_REQ_BYTECODE, we would validate and run different
> bytecode strings.
> 
> Fix this by consistently using nlmsg_find_attr everywhere.
> 
> Signed-off-by: Nelson Elhage <nelhage@ksplice.com>

Both patches look good.

Signed-off-by: Thomas Graf <tgraf@infradead.org>
