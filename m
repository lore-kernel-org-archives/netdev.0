From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive
 connections
Date: Mon, 04 May 2015 07:31:52 -0700
Message-ID: <1430749912.3711.173.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
	 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
	 <20150501201417.GB6113@akamai.com>
	 <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150501202908.GC6113@akamai.com>
	 <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150504142155.GD6113@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150504142155.GD6113-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-05-04 at 10:21 -0400, Eric B Munson wrote:

> The getsockopt() for TCP_SAVE_SYN doesn't offer much over returning 0
> from TCP_SAVED_SYN if the headers are not available. Why not collapse
> these into a single option?  If you need to track the difference between
> the headers are not avialable and should have been and the headers
> should not be available it can be done through error codes from
> getsockopt().

A single option is not good, because it adds confusion.

Note that we need to set the bit on any socket state, and doing this
with a single option is not very easy. ( You got this wrong in your
patch btw)
