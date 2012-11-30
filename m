From: wfp5p@viridian.itc.virginia.edu (Bill Pemberton)
Subject: respin of __dev* removal patches
Date: Fri, 30 Nov 2012 17:15:54 -0500
Message-ID: <20121130221555.2AA738019A@viridian.itc.virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org (Greg KH)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:33961 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab2K3WPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 17:15:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a respin of the hotplug removal patches for the networking
subsystem.  I don't want to irritate you like the big patch set did,
so before I submit them, what do you want to see that will keep your
pain to a minimum?

I've redone them so that all the __dev* removals are done at once so
there won't be one patch for __devinit, one for __devexit, etc.  I've
also broken them down into chunks following what's in the MAINTAINERS
file.  The result is 103 patches.

-- 
Bill
