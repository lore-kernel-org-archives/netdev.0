From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 14:17:31 -0700 (PDT)
Message-ID: <20071009.141731.35016624.davem@davemloft.net>
References: <m1k5pwxjxd.fsf@ebiederm.dsl.xmission.com>
	<20071009.131113.112622864.davem@davemloft.net>
	<m1tzp0vw9x.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, xemul@openvz.org, devel@openvz.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750797AbXJIVRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 17:17:32 -0400
In-Reply-To: <m1tzp0vw9x.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 09 Oct 2007 15:00:10 -0600

> Regardless it is early yet and there is plenty of time to revisit this
> after we solved the easier and less controversial problems.

Ok.

I would encourage you to learn how the SNMP mibs work, and whether
they associate things with interfaces and/or unique MAC addresses.
The semantics may have conflicts with your envisioned cluster
abstraction.
