From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH net-next] net: phy: use of_mdio_parse_addr
Date: Fri, 09 Jun 2017 19:00:54 +1000
Message-ID: <87o9txilh5.fsf@concordia.ellerman.id.au>
References: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com> <20170602.142251.851089443438560012.davem@davemloft.net> <20170607161854.GC4389@bart.dudau.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jon.mason@broadcom.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com
To: Liviu Dudau <liviu@dudau.co.uk>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607161854.GC4389@bart.dudau.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Liviu Dudau <liviu@dudau.co.uk> writes:

> On Fri, Jun 02, 2017 at 02:22:51PM -0400, David Miller wrote:
>> From: Jon Mason <jon.mason@broadcom.com>
>> Date: Wed, 31 May 2017 15:43:30 -0400
>> 
>> > use of_mdio_parse_addr() in place of an OF read of reg and a bounds
>> > check (which is litterally the exact same thing that
>> > of_mdio_parse_addr() does)
>> > 
>> > Signed-off-by: Jon Mason <jon.mason@broadcom.com>
>> 
>> Applied, thanks Jon.
>
> This makes linux-next fail the modules_install target as depmod detects 2 circular
> dependencies. Reverting this patch fixes the issue.
>
> depmod: ERROR: Cycle detected: libphy -> of_mdio -> fixed_phy -> libphy
> depmod: ERROR: Cycle detected: libphy -> of_mdio -> libphy
> depmod: ERROR: Found 3 modules in dependency cycles!
> make[1]: *** [/home/dliviu/devel/kernel/Makefile:1245: _modinst_post] Error 1
>
> This is on an ARCH=arm build, build I doubt it makes a difference. Let me know if
> you need some .config values in order to reproduce.

Same happens on 32-bit powerpc.

cheers
