From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Wed, 18 Jun 2008 12:21:48 -0600
Message-ID: <20080618182148.GD28285@obsidianresearch.com>
References: <20080610205633.11186.45499.stgit@dale> <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net> <c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com> <48513E4E.4040601@trash.net> <f8ca0a150806141103r56f0530br6b5e78943ac1c92d@mail.gmail.com> <20080614190358.GU22807@obsidianresearch.com> <48562A41.7000304@trash.net> <71d336490806180532g4ea7067akc157581cb1fa946d@mail.gmail.com> <485901A8.8060705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>,
	Amar Mudrankit <amar.mudrankit@qlogic.com>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	rdreier@cisco.com, poornima.kamath@qlogic.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([142.179.161.236]:51596 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752075AbYFRSVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 14:21:54 -0400
Content-Disposition: inline
In-Reply-To: <485901A8.8060705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 02:38:00PM +0200, Patrick McHardy wrote:

>> Currently we register netdevice only after we have made sure that
>> we can connect to the EVIC and that there are enough resources on
>> the EVIC to support this virtual ethernet interface. But if we
>> register the netdevice without making sure that we can reach the
>> EVIC and that it has resources, there is a possibility that we
>> register a netdevice that can never become active.
>
> Thats similar to a ethernet device that never has a cable
> plugged in. You should register the device with its carrier
> turned off, then change the carrier state once the connection
> has been established.

I would also encourage you to embrace this view of the VNIC as a
tunnel fully and let the administrator re-target an active netdevice
to a different VNIC without tearing down the netdevice..

The user space interface for that pretty much come for free with the
netlink implementation, one of the advantages I suppose..

Jason
