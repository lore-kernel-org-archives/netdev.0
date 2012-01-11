From: Dave Jones <davej@redhat.com>
Subject: Re: iwlwifi worse than ever in current git.
Date: Tue, 10 Jan 2012 20:42:57 -0500
Message-ID: <20120111014257.GB22066@redhat.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <4595B4D22AB93C4FABBA84AAD5AA37FD0154B1@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	Linux Wireless <linux-wireless@vger.kernel.org>
To: "Venkataraman, Meenakshi" <meenakshi.venkataraman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932778Ab2AKBm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 20:42:59 -0500
Content-Disposition: inline
In-Reply-To: <4595B4D22AB93C4FABBA84AAD5AA37FD0154B1@ORSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2012 at 10:05:25PM +0000, Venkataraman, Meenakshi wrote:
 > Hi Dan,
 > 
 > >> For the last few releases, iwlwifi has been getting consistently worse
 > >> wrt reliability for me. 
 > 
 > [MV] Do you have an approximate idea of what release the failure started occurring?
 > 
 >  The failure mode has varied, from the chip
 > >> just locking up with no tx/rx of packets with nothing being logged, to
 > >> microcode warnings, and spewing 'Tx aggregation enabled' messages over
 > >and over.
 >  
 > [MV] I'm not sure if it is related to the problem you're seeing, but I see that you're using a 5300, so can you try to load the iwlwifi module with the following parameter and see if it helps?
 > 
 > modprobe iwlagn bt_coex_active=0

Seems to make no difference at all.

	Dave
