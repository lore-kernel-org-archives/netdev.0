From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] smsc95xx: add constant definition for SMSC USB
 vendor id
Date: Mon, 15 Mar 2010 15:39:01 -0700 (PDT)
Message-ID: <20100315.153901.70730692.davem@davemloft.net>
References: <1268245959-13861-2-git-send-email-steve.glendinning@smsc.com>
	<1268245959-13861-3-git-send-email-steve.glendinning@smsc.com>
	<1268245959-13861-4-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35046
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932386Ab0COWij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:38:39 -0400
In-Reply-To: <1268245959-13861-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed, 10 Mar 2010 18:32:36 +0000

> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

I don't see any real need for this, really.  It's a constant,
device ID tables are constants and people know how to go lookup
a vendor ID if they really want to know who it is.  This doesn't
add any readability to the driver at all.

Also you're mixing cleanups and bug fixes into your patch
set.  Please seperate out the pure bug fixes so I can apply
them to net-2.6  The rest can go in later when net-next-2.6
opens up.
