From: Chris Friesen <chris.friesen@genband.com>
Subject: formal way to map from pf to vfs when using VT-d?
Date: Fri, 08 Jun 2012 14:14:16 -0600
Message-ID: <4FD25D18.6090002@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:43656 "EHLO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983Ab2FHUO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 16:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I'm using the igb/igbvf drivers.  If I set igb.max_vfs=7,7,7,7 it 
creates 7 vfs for each of my pfs.  So far so good.

Now, how do I map from a given pf to the PCI addresses for the set of 
vfs that are associated with it?  I don't have virsh installed, so is 
there a way to query this with sysfs or something?

Thanks,
Chris




-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
