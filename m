From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: Need help debugging memory corruption
Date: Sun, 4 May 2008 17:02:59 +0200
Message-ID: <e2e108260805040802l4b2bb9dfjce898903fe746a1c@mail.gmail.com>
References: <20080503130951.091392ba@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Chris Snook" <csnook@redhat.com>
To: "Jay Cliburn" <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:4299 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbYEDPDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 11:03:00 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1607002fgg.17
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 08:02:59 -0700 (PDT)
In-Reply-To: <20080503130951.091392ba@osprey.hogchain.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 3, 2008 at 8:09 PM, Jay Cliburn <jacliburn@bellsouth.net> wrote:
> Can someone with more experience than me please take a look and give me
> some advice or explain what might be happening here?  (What may be
> obvious to you is probably not obvious to me.)

Are you familiar with the kernel command-line option slub_debug=FZPU ?
If this was not yet enabled, recompiling your kernel with
CONFIG_SLUB=y and CONFIG_SLUB_DEBUG=y enabled and specifying
slub_debug=FZPU on the kernel command line will probably provide more
detailed information about the cause of the memory corruption.

Bart.
