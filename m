From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 09 Mar 2011 08:51:33 -0800
Message-ID: <1299689493.25664.120.camel@localhost.localdomain>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
	 <20110309071558.GA25757@redhat.com>
	 <201103091009.27932.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Tom Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:53887 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367Ab1CIQvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 11:51:50 -0500
In-Reply-To: <201103091009.27932.tahm@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-09 at 10:09 -0600, Tom Lendacky wrote:
> > > Vhost is receiving a lot of notifications for packets that are to
> be
> > > transmitted (over 60% of the packets generate a kick_notify). 

This is guest TX send notification when vhost enables notification.

In TCP_STREAM test, vhost exits from reaching NAPI WEIGHT, it rarely
enables the notification, vhost re-enters handle_tx from NAPI poll, so
guest doesn't do much kick_notify.

In multiple TCP_RR test, seems vhost exits from nothing to send in TX vq
very often, so it enables notification most of the time.

Shirley

