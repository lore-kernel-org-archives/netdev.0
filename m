From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 19/24] IPVS: Add IPv6 support flag to schedulers
Date: Thu, 21 Aug 2008 12:21:39 +0200
Message-ID: <f4845fc0808210321m342f2504i69d01c6b33298fc7@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <1219248931-15064-20-git-send-email-juliusv@google.com>
	 <20080821014813.GH19235@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net,
	vbusam@google.com
To: "Simon Horman" <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080821014813.GH19235@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2008 at 3:48 AM, Simon Horman wrote:
> On Wed, Aug 20, 2008 at 06:15:26PM +0200, Julius Volz wrote:
>> Add 'supports_ipv6' flag to struct ip_vs_scheduler to indicate whether a
>> scheduler supports IPv6. Set the flag to 1 in schedulers that work with
>> IPv6, 0 otherwise. This flag is checked in a later patch while trying to
>> add a service with a specific scheduler.
>
> I wonder if there are some spare bits inside the flags
> member of ip_vs_scheduler that could be used for this purpose?

Hm, there isn't any 'flags' member or similar in that struct...

> Otherwise, I'm fine with this, we can juggle things around
> later to use the other bits in supports_ipv6 for other things
> if and when the need arises.

Yes, then we could also rename it to 'flags' once needed.

> Here is a version that applies against lvs-2.6

Thanks, I guess I should start basing all of my IPVS patches on this
tree rather than net-2.6?

Julius

-- 
Google Switzerland GmbH
