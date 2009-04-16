From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
 messages
Date: Thu, 16 Apr 2009 10:45:41 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161044470.26134@qirst.com>
References: <OF0CB99079.B56E714F-ON88257599.0079319C-88257599.007A5C56@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:39309 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZDPOwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 10:52:47 -0400
In-Reply-To: <OF0CB99079.B56E714F-ON88257599.0079319C-88257599.007A5C56@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2009, David Stevens wrote:

> I know of at least one application (a JVM) in
> the wild that relies on the current behavior--
> joins are done in one process for sockets in
> another. It isn't necessarily obvious what

That is sick. Relying on operations on one socket affecting a
socket in another processs.
