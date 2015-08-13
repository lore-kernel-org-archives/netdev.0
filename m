From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Thu, 13 Aug 2015 18:06:26 +0200
Message-ID: <20150813160626.GF32484@lunn.ch>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
 <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Philip Downey <pdowney@Brocade.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 02:48:23PM +0000, Philip Downey wrote:
> Hi David
> Thanks for taking the time to review and comment.
> This is my first upstream request so please forgive any ignorance on my part.   I have added a new proposed commit wording below with a view to agreeing the content before resubmitting the patch.
> I hope it is sufficient to address your concerns.
> 
>    IGMP: Inhibit reports for local multicast groups
>     
>     The range of addresses between 224.0.0.0 and 224.0.0.255
>     inclusive, is reserved for the use of routing protocols and other
>     low-level topology discovery or maintenance protocols, such as
>     gateway discovery and group membership reporting.  Multicast
>     routers should not forward any multicast datagram with   destination
>     addresses in this range, regardless of its TTL.
> 
>     Currently, IGMP reports are generated for this reserved range of
>     addresses even though a router will ignore this information since
>     it has no purpose.

Hi Philip

What about switches which are doing IGMP snooping?

     Andrew
