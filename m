From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Mon, 8 Dec 2008 12:42:12 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A175342DB@orsmsx507.amr.corp.intel.com>
References: <491FEAD5.4090205@krogh.cc>
 <17663.1226965523@death.nxdomain.ibm.com> <49232489.4000504@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbYLHUmS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 15:42:18 -0500
In-Reply-To: <49232489.4000504@krogh.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> Jay Vosburgh wrote:
>> Jesper Krogh <jesper@krogh.cc> wrote:
>> 
>>> I have something that looks like a regression in bonding between
>>> 2.6.26.8 and 2.6.27.6 (I'll try the mid-steps later).
> 
> There was something about that rc-27 could ruin my Intel NICs.. right?
> (I'll refrain from testing with those then).

you can test 2.6.27-rcX without worry for e1000e device corruption IF
you set CONFIG_FTRACE=n

ftrace was the code that ran over the registers mapped by e1000e.

just FYI, I know this thread is ancient.
