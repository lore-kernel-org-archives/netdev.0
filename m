From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] s2io: fix documentation about intr_type
Date: Fri, 27 Jun 2008 01:34:10 -0400
Message-ID: <48647BD2.9090200@garzik.org>
References: <20080626160619.2f469b3f@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38906 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200AbYF0FeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:34:14 -0400
In-Reply-To: <20080626160619.2f469b3f@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Schmidt wrote:
> The documentation for intr_type module parameter of the s2io driver is
> not consistent with the code. The comments in drivers/net/s2io.c are
> OK, but Documentation/networking/s2io.txt is wrong.
> 
> Pointed out by Andrew Hecox.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> ---
>  Documentation/networking/s2io.txt |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/networking/s2io.txt b/Documentation/networking/s2io.txt
> index 4bde53e..1e28e2d 100644
> --- a/Documentation/networking/s2io.txt
> +++ b/Documentation/networking/s2io.txt
> @@ -83,9 +83,9 @@ Valid range: Limited by memory on system
>  Default: 30 
>  
>  e. intr_type
> -Specifies interrupt type. Possible values 1(INTA), 2(MSI), 3(MSI-X)
> -Valid range: 1-3
> -Default: 1 
> +Specifies interrupt type. Possible values 0(INTA), 2(MSI-X)
> +Valid values: 0, 2
> +Default: 2

applied


