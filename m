From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7 net-2.6.26] [TIPC]: Enhancements to message header
 writing
Date: Thu, 06 Mar 2008 15:08:20 -0800 (PST)
Message-ID: <20080306.150820.213561576.davem@davemloft.net>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
	<1204839269-30593-7-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757876AbYCFXIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:08:21 -0500
In-Reply-To: <1204839269-30593-7-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu,  6 Mar 2008 16:34:28 -0500

> This patch makes two enhancements to the routine used to
> set bit fields within a TIPC message header:
> 
>  1) It now ignores any bits of the new field value that are not
>     covered by the mask being used.  (Previously, if the new value
>     exceeded the size of the mask the extra bits could corrupt
>     other fields in the message header word being updated.)
> 
>  2) The code has been optimized to minimize the number of run-time
>     endianness conversion operations by leveraging the fact that the
>     mask (and, in some cases, the value as well) is constant and the
>     necessary conversion can be performed by the compiler.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
