From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 0/3] [NET] MTU discovery changes
Date: Fri, 23 Mar 2007 20:42:46 -0400
Message-ID: <46047406.4000902@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:54636 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970AbXCXAmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:42:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are a few changes to fix/clean up some of the MTU discovery 
processing with non-stream sockets, and add a probing mode.  See also 
matching patches to tracepath to take advantage of this.

   -John
