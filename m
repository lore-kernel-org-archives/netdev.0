From: Ben Greear <greearb@candelatech.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 19:31:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F248AE5.4000204@candelatech.com>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com> <20030727151234.6e2aa57e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bas Bloemsaat <bloemsaa@xs4all.nl>, netdev@oss.sgi.com, layes@loran.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030727151234.6e2aa57e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Sun, 27 Jul 2003 22:52:48 +0200 (CEST)
> Bas Bloemsaat <bloemsaa@xs4all.nl> wrote:
> 
> 
>>I think this is unwanted behaviour.
> 
> 
> Not a bug.  This behavior is on purpose.

What is the benefit of having it work as it does currently
in the standard kernel?  I too was supprised to find it works
this way, but have since converted to use source-routes.

Interestingly, can only use 252 or so source routes because
the rfc for netlink only gives us an 8-bit identifier for the
route id, so this still breaks if you want to run lots of
vlans or something like that.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
