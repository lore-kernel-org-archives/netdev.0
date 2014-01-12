From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v3 2/9] xen-netback: Change TX path
 from grant copy to mapping
Date: Sun, 12 Jan 2014 23:19:38 +0000
Message-ID: <52D3230A.3020203@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>	<1389139818-24458-3-git-send-email-zoltan.kiss@citrix.com>	<20140109153015.GF12164@zion.uk.xensource.com>	<52CFDAEC.5080708@citrix.com>	<20140110114534.GE29180@zion.uk.xensource.com> <52D01094.5060102@citrix.com> <52D0198C.6000600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<jonathan.davies@citrix.com>, <ian.campbell@citrix.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47024 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaALXUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 18:20:01 -0500
In-Reply-To: <52D0198C.6000600@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/14 16:02, David Vrabel wrote:
> On 10/01/14 15:24, Zoltan Kiss wrote:
> If the grant table code doesn't provide the API calls you need you can
> either:
>
> a) add the new API as a prerequisite patch.
> b) use the existing API calls and live with the performance problem,
> until you can refactor the API later on.
>
> Adding a netback-specific hack isn't a valid option.
>
> David

Ok, I've sent in the patch which does a)

Zoli
