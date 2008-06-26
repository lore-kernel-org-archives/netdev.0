From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io: fix documentation about intr_type
Date: Thu, 26 Jun 2008 13:03:05 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7703C9CAAB@nekter>
References: <20080626160619.2f469b3f@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
To: "Michal Schmidt" <mschmidt@redhat.com>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:20998 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbYFZRmH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 13:42:07 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080626160619.2f469b3f@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal,
Thanks for the fix. 

Jeff,
Please accept the patch.

Thanks,
Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Michal Schmidt
> Sent: Thursday, June 26, 2008 7:06 AM
> To: Jeff Garzik
> Cc: netdev@vger.kernel.org; Sreenivasa Honnur
> Subject: [PATCH] s2io: fix documentation about intr_type
> 
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
> diff --git a/Documentation/networking/s2io.txt
> b/Documentation/networking/s2io.txt
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
> 
>  5.  Performance suggestions
>  General:
> --
> 1.5.5.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
