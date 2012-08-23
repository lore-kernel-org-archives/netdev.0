From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 23 Aug 2012 12:41:41 -0700
Message-ID: <20120823124141.402b7b34@nehalam.linuxnetplumber.net>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41074 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759159Ab2HWTl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:41:59 -0400
In-Reply-To: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 15:29:50 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> This series of patches provides an ability to add VLAN IDs to the bridge
> ports.  This is similar to what can be found in most switches.  The bridge
> port may have any number of VLANs added to it including vlan 0 for untagged
> traffic.  When vlans are added to the port, only traffic tagged with particular
> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
> entries and become part of the lookup.  This way we correctly identify the FDB
> entry.
> 
> There are still pieces missing.  I don't yet support adding a static fdb entry
> with a particular vlan.  There is no netlink support for carrying a vlan id.
> 
> I'd like to hear thoughts of whether this is usufull and something we should
> persue.
> 
> The default behavior ofthe bridge is unchanged if no vlans have been
> configured.

Initial reaction is that this is a useful. You can already do the same thing
with ebtables, and ebtables allows more flexibility. But ebtables does slow
things down, and is harder to configure.
