From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2 PATCH 2/2] tc: Use correct variable type for
 get_distribution() result
Date: Wed, 23 Nov 2011 14:48:31 -0800
Message-ID: <20111123144831.0b51488b@nehalam.linuxnetplumber.net>
References: <4ECD6267.3090406@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56617 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801Ab1KWWse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 17:48:34 -0500
In-Reply-To: <4ECD6267.3090406@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Nov 2011 22:15:19 +0100
Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:

> get_distribution() returns an int.
> 
> cppcheck reported:
> [tc/q_netem.c:243]: (style) Checking if unsigned variable 'dist_size' is less than zero.
> 

Both applied, thanks.
