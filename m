From: Ben Greear <greearb@candelatech.com>
Subject: Re: netdev_ops?
Date: Tue, 22 Jul 2003 22:30:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E1D62.90009@candelatech.com>
References: <3F1E17BC.30100@candelatech.com> <20030722220745.379a73c6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030722220745.379a73c6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 22 Jul 2003 22:06:04 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Any progress towards getting the netdev_ops into 2.4?
>>
>>I have several patches that would benefit (in that no new ioctls
>>would be needed) if this goes in.
> 
> 
> If anything, it's going to go into 2.6.x first, and then backported
> to 2.4.x after it's had a few months of testing and tweaking.
> 
Any interest in a lower-risk netdev-ops lite?  I have a relatively
ugly little patch that will allow me to handle certain ETHTOOL ioctls in
dev.c's ioctl handling code.  Ugly, but short, and very little chance of
breaking anything else....

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
