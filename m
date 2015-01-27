From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 04/11] net/mlx4_core: Adjust command
 timeouts to conform to the firmware spec
Date: Tue, 27 Jan 2015 20:06:42 +0200
Message-ID: <20150127200642.441db19f@jpm-OptiPlex-GX620>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
	<1422367089-13419-5-git-send-email-amirv@mellanox.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3EAA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38040 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759218AbbA0SFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 13:05:41 -0500
Received: by mail-wi0-f175.google.com with SMTP id fb4so6687101wid.2
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 10:05:40 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3EAA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2015 14:30:31 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Amir Vadai
> > From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> > 
> > The firmware spec states that the timeout for all commands should
> > be 60 seconds.
> 
> Hmmm... 60 seconds seems a long time to wait for a device to do
> something.
> 
> I'll have given up and reset the machine before that expires.
> 
> 	David
> 

We have some automatic recovery features which involve resetting the
HCA upon command timeout, and we purposely give a long timeout
in order to be sure that there are no false positives
(i.e., unjustified resets).

-Jack
