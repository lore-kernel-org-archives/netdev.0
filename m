From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Use nfmark as a key for u32 classifier
Date: 05 Nov 2004 10:50:41 -0500
Message-ID: <1099669841.1026.18.camel@jzny.localdomain>
References: <Pine.LNX.4.61.0411051317330.23651@webhosting.rdsbv.ro>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Catalin(ux aka Dino)  " BOIE <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.61.0411051317330.23651@webhosting.rdsbv.ro>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think this is an ok midterm solution and should be applied.

One comment Catalin: Can you resend the patch  make this a selectable
choice via kconfig?
Eventually  - we should kill this + the indev choices on u32 and move it
up one so that we can have all filters capable of following filters from
other classifiers. As a matter of fact we already have this feature but
it is a little on the inefficient side at the moment.

cheers,
jamal 

On Fri, 2004-11-05 at 06:38, Catalin(ux aka Dino) BOIE wrote:
> Hello!
> 
> I am glad to announce a patch for u32 to allow matches on nfmark.
> The patch is non intrusive (few lines).
> 
> Why I did this? Because fw classifier cannot be used together with u32. 
> For example, now, you cannot match a mark of 0x90 and a destination 
> port of 80. I know you can do it with iptables to do the marking, but if 
> you use Jamal actions to apply mark to policed packets, you need this.
> 
> All stuff can be found at http://kernel.umbrella.ro/ also.
> 
> Dave, please consider adding this patch.
> 
> Stephen, if Dave accepts the patch, please apply the iproute2 patch. Thank 
> you.
> 
> Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
> 
> Thank you for you time.
> ---
> Catalin(ux aka Dino) BOIE
> catab at deuroconsult.ro
> http://kernel.umbrella.ro/

