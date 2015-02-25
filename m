From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch 1/2] rocker: add a check for NULL in rocker_probe_ports()
Date: Wed, 25 Feb 2015 14:55:53 +0100
Message-ID: <20150225135553.GI2039@nanopsycho.orion>
References: <20150225133532.GU19745@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150225133532.GU19745@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Feb 25, 2015 at 02:35:32PM CET, dan.carpenter@oracle.com wrote:
>Make sure kmalloc() succeeds.

Ough, nice catch. I see that the error path when rocker_probe_port fails
is also broken - I will send follow-up fix. Thanks!

>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
