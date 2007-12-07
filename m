From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/8] bonding: Remove trailing NULs from sysfs interface.
Date: Fri, 07 Dec 2007 15:02:13 -0500
Message-ID: <4759A6C5.7040701@pobox.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com> <11970132363756-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wagner Ferenc <wferi@niif.hu>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40108 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754538AbXLGUCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:02:25 -0500
In-Reply-To: <11970132363756-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> From: Wagner Ferenc <wferi@niif.hu>
> 
> From: Wagner Ferenc <wferi@niif.hu>
> 
> Also remove trailing spaces from multivalued files.
> 
> This fixes output like for example:
> 
> $ od -c /sys/class/net/bond0/bonding/slaves
> 0000000   e   t   h   -   l   e   f   t       e   t   h   -   r   i   g
> 0000020   h   t      \n  \0
> 0000025
> 
> It mostly entails deleting '+1'-s after sprintf() calls: the return value
> of sprintf is the number of characters printed, without the closing NUL,
> ie. exactly what the sysfs interface requires.  The three multivalue
> cases are different, because they also have to swallow back a trailing
> space.
> 
> Signed-off-by: Ferenc Wagner <wferi@niif.hu>
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_sysfs.c |   66 +++++++++++++++++--------------------
>  1 files changed, 30 insertions(+), 36 deletions(-)

applied 1-8 to #upstream-fixes

Your script is duplicating the "From: " line twice


