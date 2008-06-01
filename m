From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] [NET-NEXT]: Add DCB netlink interface definition
Date: Sun, 1 Jun 2008 05:16:52 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329052BDC93@orsmsx414.amr.corp.intel.com>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080527141346.12851.2280.stgit@localhost.localdomain> <20080528094140.GD20815@postel.suug.ch> <D5C1322C3E673F459512FB59E0DDC32905281CD4@orsmsx414.amr.corp.intel.com> <20080528223728.GF20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5088 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbYFAMQx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 08:16:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080528223728.GF20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There isn't much difference really, instead of using the 
> separate interface you could simply add a new link attribute 
> IFLA_DCB and issue a RTM_SETLINK/RTM_GETLINK and send the 
> same information in the same format. However, I agree with 
> you that a separate interface is better in this case as dcb 
> requests are not directly connected to other link changes at 
> all and the dcb message structure is pretty complex.
> 
> > 3. We wanted to use generic netlink, since that seems to be a more 
> > preferred method of netlink communication vs. rtnetlink.  
> And I don't 
> > know anything about the info API, so I can't comment on why 
> we didn't 
> > look at that for implementation.  Can you suggest something 
> for me to 
> > look at for the info API so I can see what that's all about?
> 
> A prominent user is the VLAN code in net/8021q/vlan_netlink.c
> 
> > Thanks Thomas.  Other than that, is there anything in the netlink 
> > interface that you would suggest to change?
> 
> Looks good from here, I didn't read it all line by line though.

Thanks Thomas for the review and comments.

Dave and Jeff, have you two taken a peek at this by chance?

Thanks,
-PJ Waskiewicz
