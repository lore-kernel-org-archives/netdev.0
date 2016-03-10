From: Amir Vadai <amir@vadai.me>
Subject: Best userspace tool to set maxrate for an interface
Date: Thu, 10 Mar 2016 16:32:30 +0200
Message-ID: <20160310143230.GA32113@office.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amir@vadai.me>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33006 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbcCJO2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 09:28:48 -0500
Received: by mail-wm0-f50.google.com with SMTP id l68so31128465wml.0
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 06:28:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

I would like to have a standard userspace tool to set the max ratelimit
of an interface.
If you remember, we added [1] a dcb netlink attribute
(DCB_ATTR_IEEE_MAXRATE) under DCB_CMD_IEEE_SET.

The natural place for it is in lldpad/dcbtool. The maxrate setting is
not part of the 8021Qaz spec, therefore it is a bit different from the
other ieee attributes. So I'm not sure it is a good place.

Where do you think it should be added?

Thanks,
Amir

[1] - 08f10af ("net/dcb: Add an optional max rate attribute")
