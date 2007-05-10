From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v4] powerpc: change rheap functions to use ulongs instead
 of pointers
Date: Thu, 10 May 2007 00:15:43 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0705100015270.27791@localhost.localdomain>
References: <11786535963742-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:62725 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755058AbXEJFUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 01:20:22 -0400
In-Reply-To: <11786535963742-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007, Timur Tabi wrote:

> The rheap allocation functions return a pointer, but the actual value is based
> on how the heap was initialized, and so it can be anything, e.g. an offset
> into a buffer.  A ulong is a better representation of the value returned by
> the allocation functions.
>
> This patch changes all of the relevant rheap functions to use a unsigned long
> integers instead of a pointer.  In case of an error, the value returned is
> a negative error code that has been cast to an unsigned long.  The caller can
> use the IS_ERR_VALUE() macro to check for this.
>
> All code which calls the rheap functions is updated accordingly.  Macros
> IS_MURAM_ERR() and IS_DPERR(), have been deleted in favor of IS_ERR_VALUE().
>
> Also added error checking to rh_attach_region().
>
> Signed-off-by: Timur Tabi <timur@freescale.com>

applied.

- k
