From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/4] dst: Distributed storage.
Date: Thu, 29 Nov 2007 15:53:23 +0300
Message-ID: <11963408033624@2ka.mipt.ru>
References: <aqqqqasdzxczc036@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:38742 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755230AbXK2Mxi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 07:53:38 -0500
In-Reply-To: <aqqqqasdzxczc036@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Distributed storage.

I'm pleased to announce the 9'th release of the distributed
storage subsystem (DST). This is maintenance release and include
bug fixing only.

DST allows to form a storage on top of local and remote nodes
and combine them into linear or mirroring setup, which in
turn can be exported to remote nodes.

Short changelog:
 * use node's size in sectors instead of bytes
 * fixed old/new ages for the first node. 
	Error spotted by Matthew Hodgson <matthew@mxtelecom.com>
 * fixed debug printk declaration
 * it is now called 'astonishingly screwed tapeworm'

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


