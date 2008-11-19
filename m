From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPv6 connect: Cannot assign requested address
Date: Tue, 18 Nov 2008 22:22:27 -0800
Message-ID: <OF8CD6A1B4.53886681-ON88257506.0022E6EA-88257506.00230359@us.ibm.com>
References: <44F951F109874751B6BF69C01ABDDC38@samsung4qkw9nm>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Mohan Lal Jangir <mohanlal@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54556 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbYKSGWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 01:22:39 -0500
In-Reply-To: <44F951F109874751B6BF69C01ABDDC38@samsung4qkw9nm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mohan,
        When using link-local addresses, you must set sin_scope_id
to the interface index.

                                                +-DLS

