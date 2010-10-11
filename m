From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH 4/4] Phonet: mark the pipe controller as EXPERIMENTAL
Date: Mon, 11 Oct 2010 12:39:29 +0530
Message-ID: <20101011070928.GC31124@bnru01.bnr.st.com>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
 <1286546523-3340-2-git-send-email-remi@remlab.net>
 <1286546523-3340-3-git-send-email-remi@remlab.net>
 <1286546523-3340-4-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:60156 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752745Ab0JKHJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 03:09:50 -0400
Content-Disposition: inline
In-Reply-To: <1286546523-3340-4-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 16:02:03 +0200, R=E9mi Denis-Courmont wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> There are a bunch of issues that need to be fixed, including:
>  - GFP_KERNEL allocations from atomic context
>    (and GFP_ATOMIC in process context),
>  - abuse of the setsockopt() call convention,
>  - unprotected/unlocked static variables...
>=20
> IMHO, we will need to alter the userspace ABI when we fix it. So mark
> the configuration option as EXPERIMENTAL for the time being (or shoul=
d
> it be BROKEN instead?).
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Thank you for this patch.
I have already started implementing 'connect()' socket call for Pipe
controller logic, as per advise of R=E9mi Denis-Courmontt. I will uploa=
d
this patch for review once I have validated GPRS/3G path (control/data)
to be working fine.

Hopefully, with all the reviews and suggestions shared on the mailing
list, existing abuse can be removed and new abuses can be avoided.

The only intention of submitting is to make Linux work smoothly with
newer devices. If there is some improper code getting introduced
unknowingly, then I will surely work on the review comments to fix it.

Thank you all!

Best regards,
Kumar.
