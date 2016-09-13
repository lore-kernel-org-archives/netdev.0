From: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: Spelling and miscellaneous neatening
Date: Tue, 13 Sep 2016 12:43:09 +0000
Message-ID: <871t0oj7hf.fsf@kamboji.qca.qualcomm.com>
References: <95a6b65277914d88178ed2b15e182455067cca60.1472490319.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <95a6b65277914d88178ed2b15e182455067cca60.1472490319.git.joe@perches.com>
        (Joe Perches's message of "Mon, 29 Aug 2016 10:05:51 -0700")
Content-Language: en-US
Content-ID: <8382662410357845AE0CE0EAA6DBD7A6@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> Correct some trivial comment typos.
> Remove unnecessary parentheses in a long line.
> Convert a return; before the end of a void function definition to just ;
>
> Signed-off-by: Joe Perches <joe@perches.com>

[...]

> --- a/drivers/net/wireless/ath/ath10k/core.c
> +++ b/drivers/net/wireless/ath/ath10k/core.c
> @@ -2118,7 +2118,7 @@ err:
>  	/* TODO: It's probably a good idea to release device from the driver
>  	 * but calling device_release_driver() here will cause a deadlock.
>  	 */
> -	return;
> +	;
>  }

I don't think this improves anything, I dropped this part from the patch
in my pending branch.

--=20
Kalle Valo=
