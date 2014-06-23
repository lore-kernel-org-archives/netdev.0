From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v3] xen-netback: bookkeep number of active
 queues in our own module
Date: Mon, 23 Jun 2014 11:18:32 +0100
Message-ID: <53A7FEF8.9090802@citrix.com>
References: <1403517017-7016-1-git-send-email-wei.liu2@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD03BC55F@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9792 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080AbaFWKSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 06:18:34 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD03BC55F@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/06/14 11:05, Paul Durrant wrote:
> 
> I do think the fact that the frontend doesn't care what algorithm
> the backend is using needs to be made explicit though. I'll see what I can
> do this week.

The specification is pretty clear. From netif.h:

 * Mapping of packets to queues is considered to be a function of the
 * transmitting system (backend or frontend) and is not negotiated
 * between the two. Guests are free to transmit packets on any queue
 * they choose, provided it has been set up correctly. Guests must be
 * prepared to receive packets on any queue they have requested be set up.

David

ps. Can you fix your email client to properly wrap your replies.
