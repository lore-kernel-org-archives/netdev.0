From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 13:45:10 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E6A@saturn3.aculab.com>
References: <1328880345.2443.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeffrey.t.kirsher@intel.com>, "Jeff Kirsher" <tarbal@gmail.com>,
	<netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37050 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754675Ab2BJNpi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 08:45:38 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11355-07 for <netdev@vger.kernel.org>;
 Fri, 10 Feb 2012 13:45:36 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1328880345.2443.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > I was thinking I might could get at least some NICs to generate Runt
frames
> > by sending small pkts and disabling frame padding, but haven't
looked into
> > it too hard yet.
> 
> I am interested by this, do you know some NICs able to disable frame
> padding ?

I'm reasonably sure some old NICs like the AMD lance will send runts.
Quite likely any that require the drives to set the padded frame length.

The same will be true when semi-generic HDLC controllers are used
to send packets from DSPs, FPGAs and SOCs.

	David
