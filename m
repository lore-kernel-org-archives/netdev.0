From: Ben Greear <greearb@candelatech.com>
Subject: Re: 100 network limit
Date: Thu, 28 Aug 2003 20:45:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4ECC52.5000406@candelatech.com>
References: <20030828180019.GH12541@krispykreme>	<20030828210855.58759b69.ak@suse.de>	<3F4E783F.6080707@candelatech.com> <20030828164143.536d8d8a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030828164143.536d8d8a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 28 Aug 2003 14:46:39 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Since you can rename devices, that might not work.  A long time ago
>>I hashed the devices, both by name and by index...that gives good
>>lookup performance, at least.  As for create-time issues, that is
>>definately slow path, and even searching linearly 4 or 8k devices is
>>not a big deal (in my opinion).  So, why not make the hard-coded 100
>>limit be more like 8196 or something really large?  (It could still
>>be adjustable if needed.)
> 
> 
> Right, it's also not going to fix the locking problems.
> 
> I would suggest two things:
> 
> 1) Ben's hashing patch for lookups.
> 
> 2) RCU'ing read access to the device list.
> 

I'm at least mostly on vacation for a week or so...  Here is a pointer
to the old patch I did..but it's ~2.5 years old.  If anyone wants
to get it working with recent code, please be my guest.

Otherwise, I'll try to get something together in a few weeks.

http://www.cs.helsinki.fi/linux/linux-kernel/2001-00/1227.html

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
