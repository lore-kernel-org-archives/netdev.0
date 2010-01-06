From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] LSM: Update comment on security_sock_rcv_skb
Date: Tue, 5 Jan 2010 21:27:42 -0600
Message-ID: <20100106032742.GA8627@us.ibm.com>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
 <1262537872.10218.27.camel@bigi>
 <m2r5q5nhbc.fsf@ssh.synack.fr>
 <201001050820.o058Kuwx087793@www262.sakura.ne.jp>
 <20100105140917.GA6624@us.ibm.com>
 <201001060023.o060Ns76078068@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jmorris@namei.org,
	sam@synack.fr, kaber@trash.net, zbr@ioremap.net,
	nhorman@tuxdriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201001060023.o060Ns76078068@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Tetsuo Handa (penguin-kernel@I-love.SAKURA.ne.jp):
> [PATCH] LSM: Update comment on security_sock_rcv_skb
> 
> It is not permitted to do sleeping operation inside security_sock_rcv_skb().
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Serge Hallyn <serue@us.ibm.com>

Thank you for sending this.

-serge

> --
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 466cbad..3696ca3 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -978,6 +978,7 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	Check permissions on incoming network packets.  This hook is distinct
>   *	from Netfilter's IP input hooks since it is the first time that the
>   *	incoming sk_buff @skb has been associated with a particular socket, @sk.
> + *	Must not sleep inside this hook because some callers hold spinlocks.
>   *	@sk contains the sock (not socket) associated with the incoming sk_buff.
>   *	@skb contains the incoming network data.
>   * @socket_getpeersec_stream:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
