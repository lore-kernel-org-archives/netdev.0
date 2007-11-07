From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [2.6 patch] unexport softnet_data
Date: Wed, 7 Nov 2007 07:01:39 -0800
Message-ID: <BAE9DCEF64577A439B3A37F36F9B691C036142EF@orsmsx418.amr.corp.intel.com>
References: <20071024162425.GI30533@stusta.de><20071026.041906.223457165.davem@davemloft.net><BAE9DCEF64577A439B3A37F36F9B691C034CC519@orsmsx418.amr.corp.intel.com> <20071106.234113.248978883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bunk@kernel.org>, <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29340 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879AbXKGPB5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 10:01:57 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071106.234113.248978883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Tuesday, November 06, 2007 11:41 PM
>
>From: "Nelson, Shannon" <shannon.nelson@intel.com>
>Date: Fri, 26 Oct 2007 08:38:55 -0700
>
>> There is no creation of a pinned_list yet in this path, so I 
>don't think
>> this would do us much good.
>
>The pinned list is created in the generic net/ipv4/tcp.c code, not in
>the address family specific code.
>
>So your comments do not apply as a reason for this patch to not go in.
>My patch has been in Linus's tree for weeks, and until you show me a
>real reason why the check shouldn't be there in the ipv6 path, it's
>staying.

Understood.

Thanks,
sln
