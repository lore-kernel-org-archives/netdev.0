From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH 1/2] can: mcp251x: fix resume when device is down
Date: Wed, 15 Jul 2015 15:17:47 +0200
Message-ID: <5f785ad6dbb16e7abe084a1d82e29efb@agner.ch>
References: <1431966808-26213-1-git-send-email-stefan@agner.ch>
 <a52e25bc10d3d669b41f19faedf82d57@agner.ch> <55A65CD5.20300@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, chripell@fsfe.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55A65CD5.20300@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-07-15 15:15, Marc Kleine-Budde wrote:
> On 07/15/2015 03:05 PM, Stefan Agner wrote:
>> Hi Marc, hi Wolfgang,
>>
>> Any comment on this two patches? I don't think these have made it in any
>> tree...
> 
> Sorry - Should I add stable in Cc for 1/2 or even both?

2/2 does not fix an actual issue, it only prevents dummy regulators
being created. It even has a slight potential of a regression, in case
the absence of a dummy regulator could not be handled properly...

But 1/2 is definitely stable material.

--
Stefan
