From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000e NVM mutex contention warnings
Date: Thu, 23 Apr 2009 15:15:02 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A29F7BE99@orsmsx507.amr.corp.intel.com>
References: <1240147024.3384.20.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"524699@bugs.debian.org" <524699@bugs.debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	"Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36226 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753390AbZDWWPF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 18:15:05 -0400
In-Reply-To: <1240147024.3384.20.camel@deadeye.i.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> What's your plan for collecting information about NVM mutex contention
> and when do you intend to remove the warnings?  I have to say I find
> this way of testing very user-unfriendly and would like to see it gone
> as soon as possible.

Hi Ben,

checking linus' tree and davem's current net-2.6 tree shows that the
code was removed as of commit: 0a834a36ac92375cd82d9e4fe4f571e257997d6a

it was put in 2/14/2009, and was included in 2.6.30-rc1 by linus.

are you suggesting that we maybe try to push to -stable too?

Jesse
