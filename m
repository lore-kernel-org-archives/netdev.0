From: akepner@sgi.com
Subject: Re: DF, IP ID always 0 and the reassembly protections
Date: Tue, 20 Jun 2006 17:38:49 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0606201735100.14498@localhost.localdomain>
References: <44988877.2030205@hp.com> <20060620.171912.70221261.davem@davemloft.net>
 <44989466.5070308@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:40676 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1751879AbWFUAmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 20:42:01 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44989466.5070308@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Jun 2006, Rick Jones wrote:
> ....
> I thought the ID's even in non-fragmented datagrams gave an idea of how many 
> IP datagrams had been sent along, and so an idea of how "unlikely" it was 
> that a datagram with holes could be reassembled?
>

Only fragmented datagrams get counted. This is arguably 
a weakness of the scheme, but it's still a big improvement 
in practice. And the more common non-fragmented datagram 
processing doesn't have to pay the price for the extra 
checks.

-- 
Arthur

