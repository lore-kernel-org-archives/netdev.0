From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 in 2.6.22 release still not detecting link
Date: Mon, 16 Jul 2007 23:59:40 +0200
Message-ID: <20070716215940.GA4170@electric-eye.fr.zoreil.com>
References: <76366b180707141531j28588861n19e2d96dd68d308a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brad@langhorst.com
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56993 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760925AbXGPWBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:01:30 -0400
Content-Disposition: inline
In-Reply-To: <76366b180707141531j28588861n19e2d96dd68d308a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Paprocki <andrew@ishiboo.com> :
[...]
> Just writing to let you know that I'm still not getting a link on
> either r8169 port with the stock 2.6.22 kernel. I haven't been able to
> get any other network interface working on this device yet, as it only
> has a mini-PCI slot and I haven't found working wireless hardware yet.
> If I had a connection, I'd try to git bisect from the last known
> working point (2.6.18), but it is difficult for me to do that given
> the current setup.

You will find a backport of the r8169 driver for the 2.6.18 kernel at
http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00
(tarball in the upper directory).

As 2.6.18 corrupts your data and 2.6.22 does not detect the link, it
could help if you tried each patch in the serie (on top of the previous
one) against 2.6.18 until the link is lost.

> Do you have any ideas about where I can place some debugging trace? I
> seem to always be able to get a link by backing off to the upstream
> Realtek driver (6.*).

Ok, that's good to know. I.e. got a link and no data corruption with
2.6.22 ?

-- 
Ueimor
