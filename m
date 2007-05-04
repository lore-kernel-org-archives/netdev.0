From: David Howells <dhowells@redhat.com>
Subject: How to find I/F to destination
Date: Fri, 04 May 2007 13:48:48 +0100
Message-ID: <5484.1178282928@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755021AbXEDMsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 08:48:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I would like to determine through which interface packets sent to a particular
UDP destination will go through, and so determine the MTU size for that
interface.  Can anyone suggest a good way of doing this from within the
kernel?

Doing this will permit AF_RXRPC to obtain a better initial guess as to the
maximum size of the packets that can be sent that way.

I could use the code Patrick gave me to allow AFS to iterate through all the
interfaces and then pick the smallest MTU, but that seems wrong somehow -
though it probably will result in the correct answer 99% of the time.

David
