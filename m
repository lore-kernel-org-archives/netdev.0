From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 10/13] xen-netfront: refactor
 claim/release grant
Date: Tue, 19 May 2015 10:19:24 +0000
Message-ID: <DE282026-6084-415C-B948-E95635CFD545@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-11-git-send-email-joao.martins@neclab.eu>
 <555A09D1.50902@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:55457 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754816AbbESKT6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:19:58 -0400
In-Reply-To: <555A09D1.50902@citrix.com>
Content-Language: en-US
Content-ID: <B02EC67F376FD049974F653C3F753A5F@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18 May 2015, at 17:48, David Vrabel <david.vrabel@citrix.com> wrote:
> On 12/05/15 18:18, Joao Martins wrote:
>> Refactors how grants are claimed/released/revoked by moving that code
>> into claim_grant and release_grant helpers routines that can be shared
>> in both TX/RX path.
> 
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>
> 
> But should this be generic?  Is it useful to other frontends?  And some
> of the line splitting looks a bit odd.

It looks like scsifront (lines 384-389, 418-423), blkfront (lines 250-257)
and netfront both grant their buffers in the same way, so perhaps these two
helpers could be reused.
