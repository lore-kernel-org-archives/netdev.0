From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH V4 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Fri, 21 Feb 2014 12:22:40 +0000
Message-ID: <53074510.2040408@citrix.com>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com> <1392659880-2538-3-git-send-email-andrew.bennieston@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD0255316@AMSPEX01CL01.citrite.net> <53074490.8030806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <Paul.Durrant@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49151 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215AbaBUMXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 07:23:07 -0500
In-Reply-To: <53074490.8030806@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> +    char *xspath = NULL;
>>
>> I don't think you need the NULL init here. xspath is set in both
>> branches of the if statement below.
> 
> Indeed, but I prefer to initialise things sanely where possible. It
> makes it easier to spot problems with later modifications of the code,
> e.g. if one of those branches changed.

Kernel style (but probably not documented anywhere) is to only
initialize locals were necessary.

David
