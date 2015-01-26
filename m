From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: improve error handling when a remote
 crashes
Date: Mon, 26 Jan 2015 15:53:51 -0500
Message-ID: <54C6A95F.8010602@oracle.com>
References: <54C6911B.5040501@oracle.com> <20150126195403.GE6437@oracle.com> <54C6A154.3090906@oracle.com> <54C6A3BA.3060004@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43820 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575AbbAZUx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:53:56 -0500
In-Reply-To: <54C6A3BA.3060004@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/26/2015 03:29 PM, Sowmini Varadhan wrote:

>>     It should only happen if there is active traffic when a remote
>> crashes, but if a remote is giving us garbage in other cases, I think an
>> admin would want to check that out.
> 
> This allows one DomU to spam up everyone else's log file by crashing
> periodically.
> 
> In any case, the contents of the message do not in any way suggest
> that an admin (of the DomU, who probably has no control over
> other DomU's anyway) should go and baby-sit some other DomU that
> just crashed.

I demoted it to a notice and we can change it to a counter when we add
stats. This way it's clear that it's an unexpected state and it's easy
to see them when we want them.

						+-DLS
