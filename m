From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V5 PATCH 0/3] Add port-profile netlink support
Date: Thu, 6 May 2010 15:51:35 +0200
Message-ID: <201005061551.35254.arnd@arndb.de>
References: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:62660 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757436Ab0EFNvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 09:51:36 -0400
In-Reply-To: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 May 2010, Scott Feldman wrote:
> The intent of this patch set is to cover both definitions of port-profile
> as defined by Cisco's enic use and as defined by VSI discover protocol (VDP),
> used in VEPA implemenations.  While both definitions are based on pre-
> standards, the concept of a port-profile to be applied to an external switch
> port on behalf of a virtual machine interface is common, as well as many
> of the fields defining the protocols.

The description no either no longer matches the patches, or you did not make the
changes that were needed based on our last discussion.

What happened to the base-device argument that you were planning to pass?

The fields that I mentioned are needed for VDP (associate/pre-associate/disassociate-flag,
VLAN ID, etc) are not there. I assume that means we should use a different
data structure for VDP, but then your description above should be updated
to state that this is no longer common for the two.

I'll follow up with a draft for VDP based on your definitions.

	Arnd
