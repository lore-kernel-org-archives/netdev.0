From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Fri, 31 Mar 2006 14:06:29 -0600
Message-ID: <C46414E1-3A15-48CF-86F9-4D1D219DC1E7@kernel.crashing.org>
References: <20060329225505.25585.30392.stgit@gitlost.site> <c0a09e5c0603301036s4e9a63e5v476d89ff8ba37760@mail.gmail.com> <351C5BDA-D7E3-4257-B07E-ABDDCF254954@kernel.crashing.org> <200603311026.33391.netdev@axxeo.de> <c0a09e5c0603311204k6b64842bm741d3e7726b39e77@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v746.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ingo Oeser" <netdev@axxeo.de>,
	"Chris Leech" <christopher.leech@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932270AbWCaUGW@vger.kernel.org>
In-Reply-To: <c0a09e5c0603311204k6b64842bm741d3e7726b39e77@mail.gmail.com>
To: "Andrew Grover" <andy.grover@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 31, 2006, at 2:04 PM, Andrew Grover wrote:

> On 3/31/06, Ingo Oeser <netdev@axxeo.de> wrote:
>> Kumar Gala wrote:
>>> Fair, but wouldn't it be better to have the association per client.
>>>
>>> Maybe leave the one as a summary and have a dir per client with
>>> similar stats that are for each client and add a per channel summary
>>> at the top level as well.
>> Such level of detail really belongs to debugging, IMHO.
> [snip]
>
> If we implemented more stats then yes debugfs sounds like it might be
> the way to go.
>
>> BTW: What is the actual frequency, at which such counters
>> will be incremented?
>
> Currently the code updates these variables (kept per cpu) every time a
> copy is queued. See include/linux/dmaengine.h.

Might it be better to update when the transfer is done incase of an  
error?

- kumar
