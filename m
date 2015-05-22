From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 02/13] xen-netback: xenbus feature persistent support
Date: Fri, 22 May 2015 10:24:37 +0000
Message-ID: <A1229035-9A90-404F-9D67-95FD39C4C14B@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-3-git-send-email-joao.martins@neclab.eu>
 <20150519151929.GA26335@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:60420 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbbEVKYx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 06:24:53 -0400
In-Reply-To: <20150519151929.GA26335@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <476C31CFBE2EA34F8D149BD148D527DC@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 May 2015, at 17:19, Wei Liu <wei.liu2@citrix.com> wrote:

> On Tue, May 12, 2015 at 07:18:26PM +0200, Joao Martins wrote:
>> Checks for "feature-persistent" that indicates persistent grants
>> support. Adds max_persistent_grants module param that specifies the max
>> number of persistent grants, which if set to zero disables persistent
>> grants.
>> 
>> Signed-off-by: Joao Martins <joao.martins@neclab.eu>
> 
> This patch needs to be moved later. The feature needs to be implemented
> first.
> 
> Also you need to patch netif.h to document this new feature. To do this,
> you need to patch the master netif.h in Xen tree then sync the change to
> Linux. Of course I don't mind if we discuss wording in the Linux
> copy then you devise a patch for Xen.

Ok, I will do that. I made the same mistake on xen-netfront.

Joao
