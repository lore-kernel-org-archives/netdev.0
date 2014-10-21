From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] mac80211: remove unnecessary null test
 before debugfs_remove
Date: Tue, 21 Oct 2014 22:05:41 +0200 (CEST)
Message-ID: <1473755457.212484.1413921941002.open-xchange@webmail.nmp.skynet.be>
References: <1413908412-5177-1-git-send-email-fabf@skynet.be> <1413918366.1998.10.camel@jlt4.sipsolutions.net>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413918366.1998.10.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 21 October 2014 at 21:06 Johannes Berg <johannes@sipsolutions.net>=
 wrote:
>
>
> On Tue, 2014-10-21 at 18:20 +0200, Fabian Frederick wrote:
> > Fix checkpatch warnings:
> >
> >=C2=A0 =C2=A0 =C2=A0WARNING: debugfs_remove(NULL) is safe this check=
 is probably not
> >required
>
> I'll apply this; however, I think that checkpatch is a just tool, and
> the commit message should reflect why you're changing the code.
> Presumably you're not doing it to make the tool happy, but to address=
 an
> issue that the tool pointed out, so I think in most cases the commit
> message should state the former, not the latter.
>
> Note that in this particular case the NULL check check could be there=
 to
> avoid a memory write (which can be significant depending on the conte=
xt)
> so blindly doing what the tool suggested wouldn't always be a good id=
ea.
>
> johannes
>

Thanks Johannes,

Maybe you can replace commit message with:
"
This patch removes NULL check before debugfs_remove.
That function already does that check and is
only called during key management so we can add some memory writes.
"

I can also resubmit patch if necessary.

Regards,
=46abian
