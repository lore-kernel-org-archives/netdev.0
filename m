From: Andre Tomt <andre@tomt.net>
Subject: Re: 2.6.10 ipv6/8021q lockup on vconfig on interface removal
Date: Thu, 20 Jan 2005 15:04:38 +0100
Message-ID: <41EFBA76.8040506@tomt.net>
References: <41EA0A01.2020707@tomt.net> <41EC0F2B.7010002@candelatech.com> <200501181014.12079.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200501181014.12079.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> Ben Greear wrote:
> 
>>Andre Tomt wrote:
>>
>>>I sent this initially about a week ago, but nobody have said anything,
>>>not even a confirmation that its beeing looked into, or about me beeing
>>>silly - highly unusual on netdev! So I'm reposting (with slight
>>>modifications), boo, shame on me. Just a bit worried it slipped through
>>>the cracks.
>>
>>My take on this is that it is a bug in the IPv6 code.  If the IPv6 people
>>think that the VLAN code might could be causing this, then I am open to
>>suggestions as to how the VLAN code might be in error....
> 
> 
> There were similar problems with tunnels in 2.6.8 and 2.6.9 kernels. They 
> seems to be gone now in 2.6.10.
> 
> Does it help, Andre?

As said in the subject, 2.6.10 exibits this. I had a similar issue 
earlier on in 2.6.8, that one got fixed with a host of other related 
ones. Then the same symptoms popped up sometime later in the development 
of the kernel; not sure exactly when this got introduced as we only ran 
our own internal 2.6.8 tree with the fix in.

I should probably do a binary search and at least pinpoint when it 
happened, but I won't have any free resources to do so until sometime 
this weekend.
