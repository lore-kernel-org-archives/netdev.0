From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Wed, 16 Jul 2008 15:49:34 +0300
Message-ID: <1ba2fa240807160549u68d9ecby25e79d832d772a0a@mail.gmail.com>
References: <20080714192302.GA2541@tuxdriver.com>
	 <20080714.204532.116542087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080714.204532.116542087.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 15, 2008 at 6:45 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Mon, 14 Jul 2008 15:23:02 -0400
>
>> Here is one last(?) round of miscellaneous patches I hope to get into
>> 2.6.27.  There are mostly driver updates, including a sizable iwlwifi
>> set of changes.
>>
>> Please let me know if there are problems!
>
> Pulled into net-next-2.6, thanks John.
>
> If someone could fix the following wireless warnings I'd appreciate
> it.
>
> Thanks!
>

> drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 6 has type 's64'
> drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 7 has type 'u64'

I cannot reproduce this. Wasn't this conversion already solved or
still need to cast to long long int?
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
