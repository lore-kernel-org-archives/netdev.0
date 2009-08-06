From: Fabio Comolli <fabio.comolli@gmail.com>
Subject: Re: WARNING: at net/mac80211/mlme.c:2292 ieee80211_sta_work+0x97/0xd2d
	[mac80211]()
Date: Thu, 6 Aug 2009 22:15:48 +0200
Message-ID: <b637ec0b0908061315s3614603dya1ac800445b748bf@mail.gmail.com>
References: <b637ec0b0908061130w399eb1c6oc3a31640a76398c5@mail.gmail.com>
	 <20090806183247.GI26809@tuxdriver.com>
	 <b637ec0b0908061226m33203bco7ac38cecb939b382@mail.gmail.com>
	 <43e72e890908061232k467ba1f7iece5d0aa9bece811@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932167AbZHFUPv@vger.kernel.org>
In-Reply-To: <43e72e890908061232k467ba1f7iece5d0aa9bece811@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Luis.
I'm using 2.6.31-rc5 and I'm not using wireless-testing.

Regards,
=46abio



On Thu, Aug 6, 2009 at 9:32 PM, Luis R. Rodriguez<mcgrof@gmail.com> wro=
te:
> On Thu, Aug 6, 2009 at 12:26 PM, Fabio Comolli<fabio.comolli@gmail.co=
m> wrote:
>> Hi John. I'm using ath5k .
>>
>> The card is a:
>>
>> 01:00.0 Ethernet controller: Atheros Communications Inc. AR5001
>> Wireless Network Adapter (rev 01)
>>
>> with PCI ID:
>>
>> 01:00.0 0200: 168c:001c (rev 01)
>
> What kernel?
>
> This is probably a driver/mac80211 adding work into the mac80211
> workqueue during the susend --> resume cycle. We recently changed the
> warning to be moved onto the actual caller who does the queue_work()
> so we don't have to guess at this and do a painful debugging.
>
> I suspect you are not using the latest wireless-testing.
>
> =C2=A0Luis
>
