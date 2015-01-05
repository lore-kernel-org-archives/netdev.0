From: nick <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers:net:wireless: Add proper locking for the function,
 b43_op_beacon_set_tim in main.c
Date: Mon, 05 Jan 2015 13:21:32 -0500
Message-ID: <54AAD62C.3000105@gmail.com>
References: <1420184041-6788-1-git-send-email-xerofoify@gmail.com>
 <87tx05378x.fsf@kamboji.qca.qualcomm.com> <54AAC6EE.2000603@gmail.com>
 <54AACE00.8060407@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
 Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <54AACE00.8060407-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


Larry,
Your right I build tested it. Unfortunately I don't have
the hardware.
Regards Nick
On 2015-01-05 12:46 PM, Larry Finger wrote:
> On 01/05/2015 11:16 AM, nick wrote:
>> Kalle,
>> That's fine. On the other hand I am interested in the
>> reasons why this patch was dropped so I can send in a
>> version 2 of this patch.
>> Regards Nick
> =

> Apparently you missed Michael B=FCsch's comment:
> =

> "Thanks for the patch.
> =

> However, this does not work. We are in atomic context here.
> Please see the b43-dev mailing list archives for a recent thread about th=
at.
> I'm also pretty sure that this is safe without lock, due to the higher le=
vel locks in mac80211."
> =

> Did you actually test the patch? If Michael is right, and I trust him on =
this matter, your patch should lock the system.
> =

> Larry
> =
