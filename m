From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [RFC 12/23] xen: Extend page_to_mfn to take an offset
 in the page
Date: Tue, 19 May 2015 15:18:24 +0100
Message-ID: <555B4630.8050304@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
	<1431622863-28575-13-git-send-email-julien.grall@citrix.com>
 <555B4167.7050506@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <stefano.stabellini@eu.citrix.com>,
	<netdev@vger.kernel.org>, <tim@xen.org>,
	<linux-kernel@vger.kernel.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>
To: David Vrabel <david.vrabel@citrix.com>,
	Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7284 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933082AbbESOV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 10:21:28 -0400
In-Reply-To: <555B4167.7050506@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 19/05/15 14:57, David Vrabel wrote:
> On 14/05/15 18:00, Julien Grall wrote:
>> With 64KB page granularity support in Linux, a page will be split accross
>> multiple MFN (Xen is using 4KB page granularity). Thoses MFNs may not be
>> contiguous.
>>
>> With the offset in the page, the helper will be able to know which MFN
>> the driver needs to retrieve.
> 
> I think a gnttab_grant_foreign_access_ref()-like helper that takes a
> page would be better.
>
> You will probably want this helper able to return/fill a set of refs for
> 64 KiB pages.

I will see what I can do.

Although, I think this patch is still valid to avoid wrong usage with
64KB page granularity by the caller.

The developer may think that MFN are contiguous which is not always true.

Regards,

-- 
Julien Grall
