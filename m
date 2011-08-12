From: Maarten Lankhorst <m.b.lankhorst@gmail.com>
Subject: Re: TCP port firewall controlled by UDP packets
Date: Fri, 12 Aug 2011 02:12:48 +0200
Message-ID: <4E447000.8070505@gmail.com>
References: <1313106969-18733-1-git-send-email-as@strmilov.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tonda <as@strmilov.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313106969-18733-1-git-send-email-as@strmilov.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2011 01:56 AM, Tonda wrote:
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -624,3 +624,7 @@
>  	  on the Internet.
>  
>  	  If unsure, say N.
> +
> +config TCPFIREWALL
> +	tristate "TCP Firewall controlled by UDP queries"
> +	depends on m

And netfilter doesn't work why?
Also, thanks to the foreign variable names, I have absolutely no clue what the code does. ;)

~Maarten
