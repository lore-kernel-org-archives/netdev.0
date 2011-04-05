From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Tue, 5 Apr 2011 22:01:53 +0200
Message-ID: <20110405200153.GA17632@merkur.ravnborg.org>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-13-git-send-email-mmarek@suse.cz> <alpine.DEB.2.00.1104051709040.7262@justus.melware.de> <1302017861.2932.13.camel@bwh-desktop> <alpine.DEB.2.00.1104051806230.7624@justus.melware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Michal Marek <mmarek@suse.cz>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Armin Schindler <armin@melware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104051806230.7624@justus.melware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2011 at 06:07:05PM +0200, Armin Schindler wrote:
> On Tue, 5 Apr 2011, Ben Hutchings wrote:
>> On Tue, 2011-04-05 at 17:10 +0200, Armin Schindler wrote:
>>> On Tue, 5 Apr 2011, Michal Marek wrote:
>>>> The kernel already prints its build timestamp during boot, no need to
>>>> repeat it in random drivers and produce different object files each
>>>> time.
>>>
>>> The module can be build separately from the kernel, therefore it can have
>>> an own build timestamp.
>> [...]
>>
>> If you want to distribute an out-of-tree version, that's your own
>> business.  It shouldn't limit what is done with the in-tree version.
>> Perhaps we could make modpost add a build timestamp to OOT modules,
>> though.
>
> I know out-of-tree stuff doesn't matter here. But I'm thinking
> about just doing 'make modules'.

If we needs this somehow a generic solution is required.
Ad hoc solutions in some modules is not the way to go.

	Sam
