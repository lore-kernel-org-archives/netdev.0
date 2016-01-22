From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/3] xen-netback: fix license ident used in
 MODULE_LICENSE
Date: Fri, 22 Jan 2016 14:34:46 +0000
Message-ID: <56A23E06.50403@citrix.com>
References: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
 <1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
 <56A22B30.3020206@citrix.com> <20160122134943.GB1691@citrix.com>
 <1453472147.4320.92.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Xen-devel <xen-devel@lists.xenproject.org>,
	"open list:XEN NETWORK BACKEND DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31506 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608AbcAVOfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jan 2016 09:35:25 -0500
In-Reply-To: <1453472147.4320.92.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/01/16 14:15, Ian Campbell wrote:
> On Fri, 2016-01-22 at 13:49 +0000, Wei Liu wrote:
>> On Fri, Jan 22, 2016 at 01:14:24PM +0000, David Vrabel wrote:
>>> On 22/01/16 12:34, Wei Liu wrote:
>>>> The comment at the beginning of the file is the canonical source of
>>>> licenses for this module. Currently it contains GPL and MIT license.
>>>> Fix
>>>> the code to reflect the reality.
>>>
>>> "The MIT license" isn't really a thing.  The closest is the X11
>>> license[1], but this not applicable here either since the text in the
>>> drivers does not refer to X11 trademarks etc.
>>>
>>
>> That was referring to the license ident string in Linux.  If MIT license
>> isn't a thing, why would Linux have it at all?
> 
> The fact what include/linux/license.h:license_is_gpl_compatible includes
> "Dual MIT/GPL" as an option seems to suggest that it is enough of a thing
> to be validly used as the contents of a MODULE_LICENSE() thing.

"Dual MIT/GPL" is used exactly once in the source in a file that has no
license text and there is no other documentation.

David
