From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Fri, 17 Apr 2009 09:28:25 -0700
Message-ID: <49E8AE29.3030702@us.ibm.com>
References: <alpine.DEB.1.10.0904161136220.15629@qirst.com> <20090416174422.GB28978@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904161508520.15835@qirst.com> <20090416.151641.220683663.davem@davemloft.net> <alpine.DEB.1.10.0904170952050.11877@qirst.com> <49E8A240.8050404@us.ibm.com> <alpine.DEB.1.10.0904171158220.13734@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	dlstevens@us.ibm.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:58701 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761726AbZDQQ22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:28:28 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3HGPPXU001446
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:25:25 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3HGSQid141808
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:28:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3HGSPH7018087
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:28:26 -0600
In-Reply-To: <alpine.DEB.1.10.0904171158220.13734@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:

>> Ideally, you could tweak OS environment configuration
>> setting, if you don't want per socket. But it cannot
>> be the default.
> 
> Would you support an additional OS config variable that would set the
> default for socket operations? Then we could have a per socket option that
> would allow overriding the OS config variable?

That would be my choice personally, because it would be
easier than scripting some solution to modify potentially
hundreds of sockets on a system...

Does that sound acceptable?

thanks,
Nivedita
