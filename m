From: Michel Lespinasse <walken@zoy.org>
Subject: Re: [Bugme-new] [Bug 12282] New: Network data corruption on eee 1000
Date: Wed, 31 Dec 2008 01:34:31 -0800
Message-ID: <20081231093431.GB28913@zoy.org>
References: <bug-12282-10286@http.bugzilla.kernel.org/> <20081223232035.5a5caea9.akpm@linux-foundation.org> <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jie Yang <jie.yang@atheros.com>
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:43409 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbYLaJec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 04:34:32 -0500
Content-Disposition: inline
In-Reply-To: <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 07:32:36AM -0600, J. K. Cliburn wrote:
> Do things improve if you turn off TSO in the atl1e driver?
> 
> ethtool -K eth0 tso off

I said yes in a previous message, but I think I was confused.

I'm now running 2.6.28 with a driver change that removes NETIF_F_TSO and
NETIF_F_TSO6 from netdev->features. Last night I transferred 180 GB
with scp without any corrupted MACs, however today while compiling stuff
over NFS I got a 128-byte block of source code that was corrupted
(replaced with text from a different source file). So, my issue does not
seem to disappear even after disabling TSO support in the driver.
Also the issue seems to be somewhat intermittent, since I was not able
to triger it at will with scp last night.... :/

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
