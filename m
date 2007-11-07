From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] always export sysctl_{r,w}mem_max
Date: Tue, 06 Nov 2007 23:50:40 -0800 (PST)
Message-ID: <20071106.235040.15743646.davem@davemloft.net>
References: <472278E3.4000909@hp.com>
	<20071026.163958.171785530.davem@davemloft.net>
	<m1d4v1whh5.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755882AbXKGHuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 02:50:44 -0500
In-Reply-To: <m1d4v1whh5.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 26 Oct 2007 18:04:22 -0600

> So if this is really something we want to stop doing we should
> be able to take a few extra moments remove the code from the
> two problem drivers, and remove the exports.

I've killed the references in dlm and rrunner in the net-2.6
tree.
