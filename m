From: Chuck Ebbert <cebbert@redhat.com>
Subject: netconsole module cannot be removed
Date: Mon, 26 Feb 2007 15:35:11 -0500
Message-ID: <45E3447F.9080706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750700AbXBZUfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 15:35:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trying to remove netconsole, rmmod goes into a tight loop with
100% CPU usage. It can't be killed with 'kill -9'. Shutdown
works, though. Kernel is 2.6.20 FC6 config, and I'm 99.9%
sure the module signing has nothing to do with this.



