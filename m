From: Armin Schindler <armin@melware.de>
Subject: Re: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Tue, 5 Apr 2011 18:07:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1104051806230.7624@justus.melware.de>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>  <1302015561-21047-13-git-send-email-mmarek@suse.cz>  <alpine.DEB.2.00.1104051709040.7262@justus.melware.de> <1302017861.2932.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Michal Marek <mmarek@suse.cz>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302017861.2932.13.camel@bwh-desktop>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2011, Ben Hutchings wrote:
> On Tue, 2011-04-05 at 17:10 +0200, Armin Schindler wrote:
>> On Tue, 5 Apr 2011, Michal Marek wrote:
>>> The kernel already prints its build timestamp during boot, no need to
>>> repeat it in random drivers and produce different object files each
>>> time.
>>
>> The module can be build separately from the kernel, therefore it can have
>> an own build timestamp.
> [...]
>
> If you want to distribute an out-of-tree version, that's your own
> business.  It shouldn't limit what is done with the in-tree version.
> Perhaps we could make modpost add a build timestamp to OOT modules,
> though.

I know out-of-tree stuff doesn't matter here. But I'm thinking
about just doing 'make modules'.

Armin
