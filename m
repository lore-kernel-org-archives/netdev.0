From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 device jumps from 12k/sec interrupts with traffic to
	over 100k/sec interrupts without traffic
Date: Tue, 15 Jul 2008 08:56:03 +0200
Message-ID: <20080715065603.GA8094@electric-eye.fr.zoreil.com>
References: <76366b180807142030y38b97508id8523b699d2baf37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35964 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935AbYGOG4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:56:09 -0400
Content-Disposition: inline
In-Reply-To: <76366b180807142030y38b97508id8523b699d2baf37@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Paprocki <andrew@ishiboo.com> :
> I'm currently running 2.6.26-rc8 (NAPI enabled) and my r8169 device is
> going a little crazy after a short time under load.
[...]
> What can I do to further debug this problem?

Can you send your complete dmesg (especially the XID line) and a complete
lspci -vvxx  of your system to identify the network device ?

The content of the /proc/interrupts file would be welcome too.

You may try http://userweb.kernel.org/~romieu/r8169/2.6.26-rc9/20080710/
but it's more or less a shot in the dark for now.

-- 
Ueimor
