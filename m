From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] driver adjusts qlen, increases CPU
Date: Fri, 04 Aug 2006 14:32:52 -0700
Message-ID: <44D3BD04.7040806@hp.com>
References: <Pine.WNT.4.63.0605100905150.1804@jbrandeb-desk.amr.corp.intel.com>	<44D39539.5040805@hp.com> <4807377b0608041407r3d27805aw649b4103bca97614@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:4774 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1161488AbWHDVcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 17:32:55 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0608041407r3d27805aw649b4103bca97614@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Out of curiousity, how does the UDP socket's SO_SNDBUF compare to the
>> queue depth?
> 
> 
> forgive my ignorance, how do i measure that?

getsockopt(SO_SNDBUF)?  I was just casting about on the possiblity that 
interactions between the depth of that queue and how much can be kept in 
the SO_SNDBUF might be involved.

rick jones
