From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtl8192e: Don't copy huge struct by value (and make it
 const).
Date: Mon, 07 Nov 2011 10:55:46 -0600
Message-ID: <4EB80D92.8050507@lwfinger.net>
References: <alpine.LNX.2.00.1111070017220.5763@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andreamrl@tiscali.it>,
	Mike McCormack <mikem@ring3k.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1111070017220.5763@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/06/2011 05:21 PM, Jesper Juhl wrote:
> rtllib_is_shortslot() takes one argument - a struct that's more than a
> kilobyte large. It should take a pointer instead of copying such a
> huge struct - and the argument might as well be declared 'const' now
> that we are at it, since it is not modified. This patch makes these
> changes.
>
> Signed-off-by: Jesper Juhl<jj@chaosbits.net>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
