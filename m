From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Wed, 10 Oct 2012 14:40:30 -0300
Message-ID: <CALF0-+V-SeaaSn++um-JcQx4vV4Bsd4D1c3mki1yNS8kvSGm7w@mail.gmail.com>
References: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
	<20121004.142335.1467206545795435493.davem@davemloft.net>
	<CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>
	<20121004.145419.1859367129463136197.davem@davemloft.net>
	<1349395795.2008.26.camel@joe-AO722>
	<alpine.DEB.2.02.1210050712590.1958@localhost6.localdomain6>
	<1349422595.2008.55.camel@joe-AO722>
	<alpine.DEB.2.02.1210051003120.1958@localhost6.localdomain6>
	<CA+MoWDp8Y0tJoBbz0nxH3Y7J0ur3TJm-dO9OM5BZVBKcbS9TpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Julia Lawall <julia.lawall@lip6.fr>, Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	mlindner@marvell.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+MoWDp8Y0tJoBbz0nxH3Y7J0ur3TJm-dO9OM5BZVBKcbS9TpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

On Wed, Oct 10, 2012 at 2:08 PM, Peter Senna Tschudin
<peter.senna@gmail.com> wrote:
> Stephen and David,
>
> I've sent V2 of the patches and they were all accepted. Thank you.
>
> I've made a template for the commit message, and then copy and paste
> function names from the code. Something like:
>
> -- // --
> The function sky2_probe() return 0 for success and negative value
> for most of its internal tests failures. There are two exceptions
> that are error cases going to err_out*:. For this two cases, the
> function abort its success execution path, but returns non negative
> value, making it dificult for a caller function to notice the error.
>
> This patch fixes the error cases that do not return negative values.
>
> This was found by Coccinelle, but the code change was made by hand.
> This patch is not robot generated.
> ...
> --//--
>
> How useful it was to have the function names when you were analyzing
> the patches? It took me a lot of time to modify the template by copy
> and paste, check if it is correct, then commit. I have some other
> similar patches to submit and I wonder if having the function names in
> the commit message helped you.
>

Having real function names in your commit message won't make it more useful.
IMHO, the problem is you're still using a template commit message,
which produces
a robot-like commit message.

Developers don't like that, we prefer to see a text written by some
guy explaining
why is this patch needed, and what it's fixing/improving from an
overall point of view.
This is not easy and takes much training.

I believe patches should help maintainers, not only add work them,
so it's important to double-triple-check the patch and
double-triple-check the commit message.

I know this is tedious and it'll slow you a bit. But it's a good
thing: it means you are working :-)

Also, in this particular case, where the coccinelle does not fix
something obvious,
then I'd say you should be *extra* careful.

Hope this helps.

    Ezequiel
