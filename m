From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: reset ring consumer during cleanup
Date: Sun, 26 Jul 2009 20:19:03 -0700 (PDT)
Message-ID: <20090726.201903.172993281.davem@davemloft.net>
References: <1248632456-24417-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49050
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755587AbZG0DS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 23:18:57 -0400
In-Reply-To: <1248632456-24417-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 11:20:56 -0700

> Reset consumer of status rings to 0 when cleaning
> up sw resources. Status rings are not deleted
> during suspend since they have napi objects.
> 
> This ensures correct rx processing across suspen-resume.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
