From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: sendfile() behavior while troubleshooting netdevice
Date: Tue, 29 Jul 2008 10:28:04 +0400
Message-ID: <20080729062804.GA7009@2ka.mipt.ru>
References: <20080728190707.329d247b@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ian@jeffray.co.uk
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:48034 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbYG2G2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 02:28:06 -0400
Content-Disposition: inline
In-Reply-To: <20080728190707.329d247b@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay.

On Mon, Jul 28, 2008 at 07:07:07PM -0500, Jay Cliburn (jacliburn@bellsouth.net) wrote:
> sendfile() + TSO + atl1 driver == corrupted file at the receiver

...

> The hosts:
> server, petrel,  r8169, 192.168.1.6,   2.6.20-1.2320.fc5
> client, sparrow, e100,  192.168.1.195, 2.6.25.6-27.fc8

...

> [jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
> connected...
> file size is 1600 bytes
> received 1592 bytes
> error: expected 1600, received 1592

I.e. trouble also happens with r8169 driver?

-- 
	Evgeniy Polyakov
