From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH] (17/42) wd
Date: Fri, 14 Nov 2003 13:55:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031114135559.A1381@sygehus.dk>
References: <200311130043.hAD0h8G30660@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <200311130043.hAD0h8G30660@mail.osdl.org>; from shemminger@osdl.org on Wed, Nov 12, 2003 at 04:43:08PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2003 at 04:43:08PM -0800, Stephen Hemminger wrote:
> Based on viro NE41-wd
> 	* switched wd to dynamic allocation
> 	* wd: fixed order of freeing bugs
> 	* wd: fixed resource leaks on failure exits
> 	* wd: fixed clobbering on autoprobe

Btw, shouldn't this (and other shared memory board drivers) call
request_mem_region() to reserve the shared memory area?

-- 
Regards,
Rask Ingemann Lambertsen
