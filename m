From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: Include header for vmalloc
Date: Sun, 05 Jan 2014 20:35:12 -0500 (EST)
Message-ID: <20140105.203512.1357051953391472623.davem@davemloft.net>
References: <20140105152401.GF18517@hansolo.jdub.homelinux.org>
	<20140105222221.GA16984@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jwboyer@redhat.com, Paul.Durrant@citrix.com,
	netdev@vger.kernel.org, ian.campbell@citrix.com,
	linux-kernel@vger.kernel.org
To: wei.liu2@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140105222221.GA16984@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Liu <wei.liu2@citrix.com>
Date: Sun, 5 Jan 2014 22:22:21 +0000

> On Sun, Jan 05, 2014 at 10:24:01AM -0500, Josh Boyer wrote:
>> Commit ac3d5ac27735 ("xen-netback: fix guest-receive-side array sizes")
>> added calls to vmalloc and vfree in the interface.c file without including
>> <linux/vmalloc.h>.  This causes build failures if the
>> -Werror=implicit-function-declaration flag is passed.
>> 
>> Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>
> 
> Acked-by: Wei Liu <wei.liu2@citrix.com>

Applied, thanks everyone.
