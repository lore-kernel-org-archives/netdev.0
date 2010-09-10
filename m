From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Possible regression with skb_clone() in 2.6.36
Date: Fri, 10 Sep 2010 10:15:33 +0000
Message-ID: <20100910101533.GA21844@ff.dom.local>
References: <1283988727-1456-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1283988727-1456-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2010-09-09 01:32, Gustavo F. Padovan wrote:
> I've been experiencing some problems when running the L2CAP Streaming mode in
> 2.6.36. The system quickly runs in an Out Of Memory condition and crash. That
> wasn't happening before, so I think we may have a regression here (I didn't
> find where yet). The crash log is below.
> 
> The following patch does not fix the regression, but shows that removing the
> skb_clone() call from l2cap_streaming_send() we workaround the problem. The
> patch is good anyway because it saves memory and time.
> 
> By now I have no idea on how to fix this.

My suggestion is to check the length of conn->data_q in hci_send_acl()
while this happens, and maybe try to set some limit here.

Jarek P.
