From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] configure: pull AR from the env too
Date: Mon, 17 Dec 2012 09:14:08 -0800
Message-ID: <20121217091408.324478ea@nehalam.linuxnetplumber.net>
References: <1355695757-9957-1-git-send-email-vapier@gentoo.org>
	<1355695757-9957-3-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org,
	jengelh@inai.de
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49903 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535Ab2LQRPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 12:15:25 -0500
In-Reply-To: <1355695757-9957-3-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2012 17:09:17 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> This matches the existing CC behavior.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  configure | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/configure b/configure
> index ea1038d..7c2db9b 100755
> --- a/configure
> +++ b/configure
> @@ -10,7 +10,9 @@ trap 'status=$?; rm -rf $TMPDIR; exit $status' EXIT HUP INT QUIT TERM
>  check_toolchain()
>  {
>  : ${PKG_CONFIG:=pkg-config}
> +: ${AR=ar}
>  : ${CC=gcc}
> +echo "AR:=${AR}" >>Config
>  echo "CC:=${CC}" >>Config
>  echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
>  }

All applied
