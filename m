From: Christopher Covington <cov@codeaurora.org>
Subject: Re: [CRIU] [PATCH 3/3] tcp: add ability to restore a fin packet
Date: Fri, 21 Mar 2014 10:04:07 -0400
Message-ID: <532C46D7.9050403@codeaurora.org>
References: <1395408781-8145-1-git-send-email-avagin@openvz.org> <1395408781-8145-4-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>, criu@openvz.org,
	Eric Dumazet <edumazet@google.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395408781-8145-4-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/2014 09:33 AM, Andrey Vagin wrote:
> It's required for restoring sockets in closing states:
> TCP_FIN_WAIT{1,2}, TCP_WAIT_STOP, TCP_CLOSING, TCP_LAST_ACK.
> 
> A fin packet is restored by sending a control message (ancillary data).
> In which queue a packet is restored depends on a value of
> tp->repair_queue.
> 
> This interface is choosen, because we are goint to use sendmsg for

Nit: chosen, going

> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -199,4 +199,7 @@ struct tcp_md5sig {
>  	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
>  };
>  
> +/* Conntroll message types to repair tcp connections */

Nit: Control

Christopher

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by the Linux Foundation.
