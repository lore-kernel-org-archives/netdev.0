From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: crash in tcp_fragment
Date: Tue, 28 Feb 2012 01:18:36 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1202280115020.17924@melkinpaasi.cs.helsinki.fi>
References: <1330311465.2552.23.camel@boudreau>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Tim Hartrick <tim@edgecast.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42696 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044Ab2B0XSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 18:18:38 -0500
In-Reply-To: <1330311465.2552.23.camel@boudreau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Feb 2012, Tim Hartrick wrote:

> 	We have been seeing the crash cited below on a number of our systems
> running kernel version 2.6.34, 2.6.36 and 2.6.38 using a number of
> different GigE controllers.  I note that commit
> 2fceec13375e5d98ef033c6b0ee03943fc460950 introduced a band-aid for the
> problem by replacing the BUG_ON() to a WARN().  I have two questions
> related to this.
> 
> 1) Is there a fix for the root cause?  Can I get a pointer to the commit
> that claims to address the root cause?

There have been multiple fixes recently on the counters which this code 
depends on, however, nobody has afaict fully analyzed what else those 
fixed.

> 2) Will disabling GSO/TSO make the problem go away?  That is, is
> something related to GSO/TSO at the root of the problem?

Very likely.

-- 
 i.
