From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: socket: fixed coding style issues.
Date: Mon, 11 Jun 2012 18:53:23 +0100
Message-ID: <1339437203.2665.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339420656-11512-1-git-send-email-shaw500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@emloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Matthew Shaw <shaw500@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339420656-11512-1-git-send-email-shaw500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 14:17 +0100, Matthew Shaw wrote:
> Fixed an instance where brances are used but not needed, and some lines
> in the comments and code that exceed the 80 character limit.
> 
> Signed-off-by: Matthew Shaw <shaw500@gmail.com>
> ---
>  net/socket.c |  137 ++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 75 insertions(+), 62 deletions(-)
> 
> diff --git a/net/socket.c b/net/socket.c
> index 6e0ccc0..2133040 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -8,48 +8,48 @@
>   *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
>   *
>   * Fixes:
> - *		Anonymous	:	NOTSOCK/BADF cleanup. Error fix in
> - *					shutdown()
> - *		Alan Cox	:	verify_area() fixes
> - *		Alan Cox	:	Removed DDI
> - *		Jonathan Kamens	:	SOCK_DGRAM reconnect bug
[...]

I would question whether such lists of bug fixes are worth keeping at
all.  The names should probably be kept as credits, but the details are
ancient history now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
