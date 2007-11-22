From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 12:54:49 +0100
Message-ID: <200711221254.50256.ak@suse.de>
References: <20071122343.446909000@suse.de> <20071122110622.GB4552@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60205 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbXKVL7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 06:59:08 -0500
In-Reply-To: <20071122110622.GB4552@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 November 2007 12:06, Christoph Hellwig wrote:
> Very nice, looking forward to organize the exports mess a bit more.

I would need people to help me converting more subsystems to this new scheme.

In particular all exports that are only used by a single module are direct 
candidates for a namespace. For the others it has to be checked by someone
who knows the particular subsystem well.

e.g. for SCSI it would be nice to put the symbols only used by sd/sr/sg etc.
into a namespace.

-Andi
