From: Patrick McHardy <kaber@trash.net>
Subject: Re: Leaked net-device reference in eql.c
Date: Sat, 27 Aug 2005 05:38:06 +0200
Message-ID: <430FE01E.9020600@trash.net>
References: <430FAF0D.5050000@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <430FAF0D.5050000@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I think the eql_s_slave_cfg method in eql.c leaks
> the reference to slave_dev.  Am I missing something?

No, it should also put the device, as in eql_g_slave_cfg.
