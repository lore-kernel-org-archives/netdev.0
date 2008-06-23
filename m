From: Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Mon, 23 Jun 2008 09:57:30 +0300
Message-ID: <87d4m88wpx.fsf@nokia.com>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi>
	<43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Adrian Bunk" <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890806220804i347b942claae7b725231afcce-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (ext Luis R. Rodriguez's message of "Sun\, 22 Jun 2008 20\:34\:10 +0530")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Sun, Jun 22, 2008 at 6:25 PM, Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org> wrote:
>> After the scheduled removal of MAC80211_RC_SIMPLE only
>> MAC80211_RC_DEFAULT_PID and MAC80211_RC_DEFAULT_NONE are
>> left as choices.
>>
>> Does MAC80211_RC_DEFAULT_NONE have any userbase serious enough to
>> justify all the constructs made for this case or could we simply
>> always enable MAC80211_RC_PID?
>
> You can currently only get away living without it if you are just
> using iwl3945 or iwl4965 as they provide their own rate control
> algorithms. In the future if other vendor drivers are added with their
> own rate control algorithm this list grows. Disabling PID will save
> you some space only on some embedded platforms. Although currently its
> not evident people would do this I do see this being a reasonable
> option to keep around for later.

I agree with Luis. There is a need for MAC80211_RC_DEFAULT_NONE,
please do not remove it.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
