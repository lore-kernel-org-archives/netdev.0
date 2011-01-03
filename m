From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: Fix section mismatch from the temac_of_probe
Date: Mon, 03 Jan 2011 12:07:52 -0800 (PST)
Message-ID: <20110103.120752.15260093.davem@davemloft.net>
References: <1294050756-31099-1-git-send-email-monstr@monstr.eu>
	<20110103170332.GB2522@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: monstr@monstr.eu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: grant.likely@secretlab.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110103170332.GB2522@angua.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>
Date: Mon, 3 Jan 2011 10:03:32 -0700

> On Mon, Jan 03, 2011 at 11:32:36AM +0100, Michal Simek wrote:
>> Replace __init by __devinit.
>> 
>> Warning message:
>> WARNING: vmlinux.o(.data+0xbc14): Section mismatch in reference from the variable
>> temac_of_driver to the function .init.text:temac_of_probe()
>> The variable temac_of_driver references
>> the function __init temac_of_probe()
>> If the reference is valid then annotate the
>> variable with __init* or __refdata (see linux/init.h) or name the variable:
>> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
>> 
>> Signed-off-by: Michal Simek <monstr@monstr.eu>
> 
> Acked-by: Grant Likely <grant.likely@secretlab.ca>

Applied, thanks everyone.
