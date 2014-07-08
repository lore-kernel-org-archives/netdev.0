From: Flavio Leitner <fbl@redhat.com>
Subject: Re: RSS is not efficient when forwarding (ixgbe)
Date: Mon, 7 Jul 2014 21:28:37 -0300
Message-ID: <20140708002837.GS2346@t520.home>
References: <20140703224408.GA2343@t520.home>
 <20140704193644.GB2343@t520.home>
 <CA+mtBx-dY2eoDzL-1K8F8Br224H+c4fzVtVPu9JmnjLdQKuAOg@mail.gmail.com>
 <20140707105523.GC2343@t520.home>
 <F6FB0E698C9B3143BDF729DF2228664685DCFE12@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754749AbaGHA2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2014 20:28:43 -0400
Content-Disposition: inline
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664685DCFE12@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2014 at 04:33:24PM +0000, Skidmore, Donald C wrote:
> 
> 
> > 
> > It's a router forwarding traffic from one interface to another, so I guess it's
> > only the kernel. BTW, no firewall.
> > 
> > Flow Director needs to be enabled and I am using defaults.
> 
> Flow Director in ATR mode is on by default for ixgbe.  So like Tom mentioned the driver will create hash buckets for egress packets.  You could try disabling ATR and just use RSS.  Which would probably be the right thing to do any way since Flow Director isn't very useful for routing scenarios.  

That was it.
Thanks a lot
fbl
