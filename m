From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on powerpc	selectsCONFIG_INTEL_IOATDMA=y
Date: Tue, 14 Oct 2008 09:10:33 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52066E36C7@orsmsx418.amr.corp.intel.com>
References: <20081013101559.GA14372@linux.vnet.ibm.com> <20081013112631.GD29938@cs181140183.pp.htv.fi> <36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com> <48F391B9.1000206@myri.com> <20081013183503.GA28133@cs181140183.pp.htv.fi> <48F4627E.30300@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Adrian Bunk" <bunk@kernel.org>,
	"Kamalesh Babulal" <kamalesh@linux.vnet.ibm.com>,
	"Jeff Garzik" <jgarzik@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	<linux-kernel@vger.kernel.org>, <apw@shadowen.org>,
	<linuxppc-dev@ozlabs.org>, <sam@ravnborg.org>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>
To: "Brice Goglin" <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59290 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbYJNQLT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 12:11:19 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48F4627E.30300@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Adrian Bunk wrote:
>> But considering that igb is in a similar situation it would be nice
>> if all 3 drivers would handle it the same way.
>> 
> 
> Jesse,
> What do you think of the below patch?

Seems like a much better solution.  I can have Jeff Kirsher work on the
equivalent patches for igb, and ixgbe today.

> I am not very familiar with Kconfig, but it seems to solve the
> problem. 
> If a Kconfig guru could double-check...

Yeah, please Kconfig gurus on the list have a quick look.

