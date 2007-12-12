From: drago01 <drago01-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Wed, 12 Dec 2007 19:39:59 +0100
Message-ID: <f6ca9fed0712121039n1c287f48n7ece3107bd0b50ca@mail.gmail.com>
References: <1197483844.6558.158.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Michael Wu" <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	"Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Jouni Malinen" <j@w1.fi>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1197483844.6558.158.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Dec 12, 2007 7:24 PM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> [comments welcome. I really need a refresher on what the frame formats
> mean but I think I did the right thing with skb->protocol here, I also
> think we had a bug with rfc2042 header frames bigger than 15xx bytes and
> eth_type_trans()]
>
> This cleans up the frame receive handling. After this patch
>  * EAPOL frames addressed to us or the EAPOL group address are
>    always accepted regardless of whether they are encrypted or not

why? userspace (wap_supplicant) tryes to control this depending on the
network settings.
(I don't really know why thought)
maybe it should be handled like drop_unencrypted with default to accept all?
