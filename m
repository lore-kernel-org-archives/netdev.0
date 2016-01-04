From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: rsi: Delete unnecessary variable initialisations in rsi_send_mgmt_pkt()
Date: Tue, 5 Jan 2016 10:54:19 +1100
Message-ID: <CAGRGNgXw+G6ZcmFmM=VWZT_jibuZyxe-kSvPSF8W7hPueLhNrw@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net> <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net> <20160104092857.GD5284@mwanda>
 <568A4CFF.8060600@users.sourceforge.net> <20160104114849.GH5284@mwanda> <568A668D.8090007@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <568A668D.8090007-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On Mon, Jan 4, 2016 at 11:33 PM, SF Markus Elfring
<elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> wrote:
>>> May I resend a consistent patch series for the source file
>>> "drivers/net/wireless/rsi/rsi_91x_pkt.c" in the near future?
>>
>> If you were sending checkpatch.pl fixes that would be easier to deal with
>
> Does this feedback mean that you would accept any more suggestions around
> source code updates which are derived from recommendations of this script?

A good rule of thumb here would be that if people start complaining
about a particular type of change, stop sending them.

Another good rule of thumb is to try to "rock the boat" on coding
style and conventions as little as possible. Just because it's
possible doesn't mean that people want to do it.

That said, if you figure out some change that produces significant
reductions in code or binary size on multiple architectures without
making things more complicated, less readable or making the code or
binary size larger, then by all means propose it. "This makes things
smaller" carries much more weight than "I think this is better".
Almost all of the changes you've proposed that have seen any
discussion whatsoever fall into the latter category.

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
