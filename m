From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 hangs without any messages
Date: Wed, 23 May 2007 07:50:26 -0700
Message-ID: <20070523075026.3f78e306@freepuppy>
References: <20070523075431.GA15935@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:39660 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755780AbXEWOue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 10:50:34 -0400
In-Reply-To: <20070523075431.GA15935@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 May 2007 09:54:31 +0200
Tino Keitel <tino.keitel@tikei.de> wrote:

> Hi folks,
> 
> in the last 2 days, I had 2 outages of the NIC of my Mac mini Core Duo.
> I checked the kernel log but I found nothing sky2 related. After
> reloading the module, the interface worked again.
> 
> Both freezes were connected to access from a remote NFS client to a
> directory with ~4700 files in it. Both times, after reloading the
> module and waiting some minutes until the NFS client had recovered from
> the hanging NFS server, the same action worked.
> 
> The network is 100 mbit full duplex. I use NFS over TCP and kernel
> 2.6.21 with the "disable flow control" patch, the configuration is
> attached.
> 

Don't use that patch, it isn't needed and probably causes problem.

Please get output of 'ethtool -d eth0'; more recent versions of
ethtool can decode the register format. Older versions just print hex.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
