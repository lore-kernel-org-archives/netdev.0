From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pl25a1_support
Date: Wed, 30 Mar 2011 02:40:04 -0700 (PDT)
Message-ID: <20110330.024004.45902973.davem@davemloft.net>
References: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, david-b@pacbell.net
To: simon@mungewell.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Wood <simon@mungewell.org>
Date: Tue, 29 Mar 2011 21:44:27 -0600

> @@ -89,13 +97,17 @@ static int pl_reset(struct usbnet *dev)
>  	/* some units seem to need this reset, others reject it utterly.
>  	 * FIXME be more like "naplink" or windows drivers.
>  	 */
> -	(void) pl_set_QuickLink_features(dev,
> +	int     status;
> +
> +        status = pl_set_QuickLink_features(dev,
>  		PL_S_EN|PL_RESET_OUT|PL_RESET_IN|PL_PEER_E);

Poor indentation here in the status assignment, there should be
only a single TAB character before "status =".

Also, declare the local variable at the beginning of the function,
before the function, not after it.  And get rid of that tab between
"int" and "status, like this:

	int status;

	/* some units seem to need this reset, others reject it utterly.
	 * FIXME be more like "naplink" or windows drivers.
	 */
