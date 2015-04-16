From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Fix error handling in mv88e6xxx_set_port_state
Date: Thu, 16 Apr 2015 05:51:46 -0700
Message-ID: <552FB062.5090307@roeck-us.net>
References: <1429161162-2028-1-git-send-email-linux@roeck-us.net> <20150416123742.GG13105@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150416123742.GG13105@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/16/2015 05:37 AM, Andrew Lunn wrote:
> On Wed, Apr 15, 2015 at 10:12:42PM -0700, Guenter Roeck wrote:
>> Return correct error code if _mv88e6xxx_reg_read returns an error.
>>
>> Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging support")
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> Hi Guenter
>
> Good catch. I'm surprised there is no compiler warning, possibly used
> before set.
>
There was, actually. No idea how I missed that. Fengguang's build bots caught it.

> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>
Thanks!

Guenter
