From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: always add flag an address that failed DAD with
 DADFAILED
Date: Fri, 8 Jan 2016 14:49:50 +0100
Message-ID: <568FBE7E.3060105@stressinduktion.org>
References: <1452257243-19389-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452257243-19389-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.01.2016 13:47, Lubomir Rintel wrote:
> The userspace needs to know why is the address being removed so that it can
> perhaps obtain a new address.
>
> Without the DADFAILED flag it's impossible to distinguish removal of a
> temporary and tentative address due to DAD failure from other reasons (device
> removed, manual address removal).
>
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Makes sense.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
