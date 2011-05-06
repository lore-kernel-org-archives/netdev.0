From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC v3 02/10] Revert "lsm: Remove the socket_post_accept() hook"
Date: Fri, 6 May 2011 13:27:15 -0400
Message-ID: <201105061327.15339.paul.moore@hp.com>
References: <1304432663-1575-1-git-send-email-sam@synack.fr> <201105060643.JBD90633.MOQJtSFFLFHOOV@I-love.SAKURA.ne.jp> <87iptop4di.fsf@synack.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: Samir Bellabes <sam@synack.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87iptop4di.fsf@synack.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, May 06, 2011 5:25:45 AM Samir Bellabes wrote:
> the main argument for socket_post_accept is to known informations of the
> remote inet.
> 
> from socket_accept(), we have no clue of who (inet->daddr and inet->saddr)
> is connecting to the local service. with socket_post_accept(), inet->daddr
> and inet->saddr are filled with the true distant informations.
> 
> This informations is interesting for next security operations on the
> socket. (we known with who we are talking to).

Looking at the snet_socket_post_accept() hook, I believe all of the 
information you are looking for should be available to you in the sock_graft() 
hook.

--
paul moore
linux @ hp
