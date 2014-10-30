From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net 1/2] drivers/net: Disable UFO through virtio
Date: Thu, 30 Oct 2014 11:47:29 -0700
Message-ID: <1414694849.15352.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414693592.16849.61.camel@decadent.org.uk>
	<1414693632.16849.62.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414693632.16849.62.camel@decadent.org.uk>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


On Thu, 2014-10-30 at 18:27 +0000, Ben Hutchings wrote:


> +		{
> +			static bool warned;
> +
> +			if (!warned) {
> +				warned = true;
> +				netdev_warn(tun->dev,
> +					    "%s: using disabled UFO feature; please fix this program\n",
> +					    current->comm);
> +			}
>

It might be time to add netdev_warn_once() ;)

Alternatively, you could use 
	pr_warn_once("%s: using disabled UFO feature; please fix this program\n",
		     tun->dev->name, current->comm);
