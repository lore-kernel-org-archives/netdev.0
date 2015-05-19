From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC 07/23] net/xen-netfront: Correct printf format
 in xennet_get_responses
Date: Tue, 19 May 2015 14:53:03 +0100
Message-ID: <555B403F.3030708@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
 <1431622863-28575-8-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <stefano.stabellini@eu.citrix.com>,
	<netdev@vger.kernel.org>, <tim@xen.org>,
	<linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431622863-28575-8-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/05/15 18:00, Julien Grall wrote:
> rx->status is an int16_t, print it using %d rather than %u in order to
> have a meaningful value when the field is negative.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
