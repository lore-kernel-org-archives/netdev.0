From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Sun, 15 Jul 2012 10:35:10 -0300
Message-ID: <20120715133510.GA5484@khazad-dum.debian.net>
References: <4FFE40A9.4060807@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F02D7@ORSMSX102.amr.corp.intel.com>
 <4FFE6BB9.4060106@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F033B@ORSMSX102.amr.corp.intel.com>
 <4FFE787B.9050201@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
 <4FFF61BD.1060604@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F11FF@ORSMSX102.amr.corp.intel.com>
 <4FFFA532.1030208@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F2354@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Jin <joe.jin@oracle.com>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:51881 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751535Ab2GONfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 09:35:14 -0400
Content-Disposition: inline
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891274F2354@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Jul 2012, Dave, Tushar N wrote:
> Somehow setting max payload to 256 from BIOS does not set this value for all devices. I believe this is a BIOS bug.

And preferably, Linux should complain about it.  Since we know it is going
to cause problems, and since we know it does happen, we should be raising a
ruckus about it in the kernel log (and probably fixing it to min(path) while
at it)...

Is this something that should be raised as a feature request with the
PCI/PCIe subsystem?

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
