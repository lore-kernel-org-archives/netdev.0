From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 21:00:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB61EFB.4020401@candelatech.com>
References: <Pine.GSO.4.30.0210222340520.24323-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> What i recall is 64 was a good number and thats why we had it as default.
> I cant remember who changed the value to 16(Robert?), but it does seem to
> be a good value as well. If that was the only driver and it had a lot of
> packets, it would still get to use all the 300 packets in the budget; it
> will just have to do it in 300/16 times ..

Is there any way to influence how often the poll loop gets run?

I'll have a patch to set the weight via IOCTL soon....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
