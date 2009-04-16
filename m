From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: zero features for a vlan over bond / vlan features
Date: Thu, 16 Apr 2009 17:11:32 +0300
Message-ID: <49E73C94.5030009@Voltaire.com>
References: <Pine.LNX.4.64.0904061556140.32757@zuben.voltaire.com> <6223.1239113811@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:25953 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752484AbZDPOLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 10:11:44 -0400
In-Reply-To: <6223.1239113811@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> The features system now has a dev->vlan_features that lists the
> features that will work through a vlan; bond_compute_features isn't
> using netdev_increment/fix_features to additionally compute the vlan_features, 
> so that's ending up always empty even if the underlying device supports vlan passthrough.
> I'm working on a patch; I'll see what I can come up with.  

Great, I will be happy to test the patch once you have it...

> Note, however, that at this writing, the set of drivers that explicitly
> supports VLAN passthrough (a non-zero vlan_features) is rather limited.

Please correct me if I'm wrong - would be it correct to say that there's a concept 
of "VLAN acceleration" which comes into play when the NIC device advertises  
NETIF_F_HW_VLAN_xxx features and a concept of "VLAN passthrough" which means the
NIC device have a non empty vlan_features bit mask? 

Looking on Linus tree I noted that indeed only few drivers have non-empty vlan_features
and I wonder if the reason for that is indeed lack of HW support or just the driver
maintainers being somehow slow to catch up with the vlan_features concept, Dave - 
any insight here? 

Or.
