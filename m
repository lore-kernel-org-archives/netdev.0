From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH v2 12/13] QLogic VNIC: Driver Kconfig and Makefile.
Date: Mon, 26 May 2008 14:47:29 -0700
Message-ID: <adaod6s4u1a.fsf@cisco.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	<20080519103730.12355.14730.stgit@localhost.localdomain>
	<adamyme57ir.fsf@cisco.com>
	<71d336490805260037y4c45abd5lccd5dbadebd84eb8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:29889 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbYEZVrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 17:47:36 -0400
In-Reply-To: <71d336490805260037y4c45abd5lccd5dbadebd84eb8@mail.gmail.com>
	(Ramachandra K.'s message of "Mon, 26 May 2008 13:07:28 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > The debugging code is always compiled in and is controlled
 > at run time through vnic_debug module parameter.
 > INFINIBAND_QLGC_VNIC_DEBUG config option only controls verbose debugging
 > which adds some extra information in the debug statements (file name,
 > line number)
 > which we typically use for debug builds of the driver.  Even if this option is
 > set to 'n', users can still get all debug messages from the driver by using the
 > vnic_debug module parameter.

OK, I looked at the code.  Is there any point to having
CONFIG_INFINIBAND_QLGC_VNIC_DEBUG at all??  Is anyone going to care
about having __FILE__ and __LINE__ included in the output and want to
set this option to 'n'?

 - R.
