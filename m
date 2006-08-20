From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 19:15:56 +0100
Message-ID: <1156097756.4051.28.camel@localhost.localdomain>
References: <20060819230532.GA16442@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <wtarreau@hera.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:23490 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1751097AbWHTRzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 13:55:45 -0400
To: Solar Designer <solar@openwall.com>
In-Reply-To: <20060819230532.GA16442@openwall.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Sul, 2006-08-20 am 03:05 +0400, ysgrifennodd Solar Designer:
> The patch makes getsockopt(2) sanity-check the value pointed to by
> the optlen argument early on.  This is a security hardening measure
> intended to prevent exploitation of certain potential vulnerabilities in
> socket type specific getsockopt() code on UP systems.
> 
> This change has been a part of -ow patches for some years.

Is it in 2.6 ?

