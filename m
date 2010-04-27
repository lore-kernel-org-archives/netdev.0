From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 17:15:58 -0700
Message-ID: <20100427001558.GN15278@x200.localdomain>
References: <C7FB6E1B.2BC18%scofeldm@cisco.com>
 <C7FB77DB.2BC42%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab0D0AQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 20:16:16 -0400
Content-Disposition: inline
In-Reply-To: <C7FB77DB.2BC42%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Scott Feldman (scofeldm@cisco.com) wrote:
> Hmmm...seems IFLA_NUM_VF assumes a PCI device supporting SR-IOV when it uses
> dev_num_vf().  I think a better option would have been to query the device
> for the number of VFs, without assuming SR-IOV or even PCI.
> 
> I see a ndo_get_num_vf() coming...

That was discussed when the patch originally merged.  The proposal to make
get/set symmetric.  Right now it's an unusual mix of sets + one
collective get.

thanks,
-chris
