From: "David S. Miller" <davem@redhat.com>
Subject: Re: [DOCUMENTATION PATCH] Missing net sysctls, some fixed, rest
 flagged
Date: Wed, 16 Jun 2004 11:15:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616111531.6047bb40.davem@redhat.com>
References: <20040609175242.GA13875@outpost.ds9a.nl>
	<20040615201912.691ffe35.davem@redhat.com>
	<40D006BF.7020002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <40D006BF.7020002@cosmosbay.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2004 10:37:19 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> I dont agree with the 'TCP' word here : listen() system call is not tied 
> with TCP, isn't it ?
> I would suggest :
> 
> +somaxconn - INTEGER
> +	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
> +	Defaults to 128. See also tcp_max_syn_backlog for additional tuning for TCP sockets.
> +

Works for me.  Applied.
