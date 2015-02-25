From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch 2/2] rocker: silence shift wrapping warning
Date: Wed, 25 Feb 2015 14:44:05 +0100
Message-ID: <20150225134405.GG2039@nanopsycho.orion>
References: <20150225133612.GV19745@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150225133612.GV19745@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Feb 25, 2015 at 02:36:12PM CET, dan.carpenter@oracle.com wrote:
>"val" is declared as a u64 so static checkers complain that this shift
>can wrap.  I don't have the hardware but probably it's doesn't have over

It's a QEMU hardware, you can have it easily.

>31 ports.  Still we may as well silence the warning even if it's not a
>real bug.

It can have up to 62 ports.

>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
