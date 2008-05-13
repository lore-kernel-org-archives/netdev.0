From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5
	Option Error while receive invalid option
Date: Tue, 13 May 2008 09:30:33 +0100
Message-ID: <20080513083033.GA11707@gerrit.erg.abdn.ac.uk>
References: <48294E9C.4060209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33808 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759211AbYEMIaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 04:30:46 -0400
Content-Disposition: inline
In-Reply-To: <48294E9C.4060209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Wei Yongjun:
> If endpoint received invalid option, it must reset the connection with  
> Reset Code 5 "Option Error", but current kernel send reset with Reset  
> Code 4 "Packet Error".
>
Ack. However, this has already been fixed in the test tree where dccp_parse()
both sets the Reset code and fills in the Data1..3 fields (not done by this patch).

Within a span of two weeks this is the fourth DCCP patch which fixes bugs
that already have fixes in the DCCP test tree. The same problems are fixed
in two different locations.

If you are doing DCCP work, please consider 
http://www.linux-foundation.org/en/Net:DCCP_Testing#How_to_obtain
