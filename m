From: Andi Kleen <ak@suse.de>
Subject: Re: Netpoll client software?
Date: Wed, 15 Nov 2006 07:27:52 +0100
Message-ID: <200611150727.52828.ak@suse.de>
References: <F3EE2A9EB4576F40AFE238EC0AC04BC5099B8C7A@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:13791 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S966537AbWKOG2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 01:28:05 -0500
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
In-Reply-To: <F3EE2A9EB4576F40AFE238EC0AC04BC5099B8C7A@orsmsx402.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 November 2006 20:38, Williams, Mitch A wrote:
> Hi folks, I'm looking for some suggestions for software that uses
> the kernel's netpoll interface to receive packets.  The only in-kernel
> application that uses netpoll right now is netconsole, and that only
> sends packets.

There are kgdb version that support debugging over ethernet. That requires
sending and receiving. Not sure if it works right now with the version in 
-mm* though.

-Andi
