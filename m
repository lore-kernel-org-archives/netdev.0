From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-05-21
Date: Fri, 22 May 2015 14:38:05 +0200
Message-ID: <CA+BoTQneUoKq_Gh=A=-=RLn7TUrfdAm8UwQkUvJGgBDDwaqKpA@mail.gmail.com>
References: <87k2w26oef.fsf@kamboji.qca.qualcomm.com>
	<CA+BoTQmukTiNFrsLA5rdiQe=Ga45JNuFzSmqQ4h-VJMW97f=_w@mail.gmail.com>
	<87r3q84x1j.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87r3q84x1j.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 22 May 2015 at 14:27, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org> writes:
>> On 21 May 2015 at 15:39, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
[...]
>>> + static int ath10k_vdev_start_restart(struct ath10k_vif *arvif,
>>> +                                    const struct cfg80211_chan_def=
 *chandef,
>>> +                                    bool restart)
>>>   {
>>>         struct ath10k *ar =3D arvif->ar;
>>> -       struct cfg80211_chan_def *chandef =3D &ar->chandef;
>>>         struct wmi_vdev_start_request_arg arg =3D {};
>>>  -      int ret =3D 0, ret2;
>>>  +      int ret =3D 0;
>>>
>>>         lockdep_assert_held(&ar->conf_mutex);
>>>
>>
>> Kalle, I'm not seeing this when I merge your pull tag on top of
>> net-next/master. Am I missing something?
>
> You lost me, you are not seeing what?

Your merge resolution diff seems to include stuff regarding
ath10k_vdev_stop(). I didn't see it when I tried the merge and had
only 2 conflicts: the promisc code and at feature flags (XMIT_FAST).


> I think we have a misunderstanding

That's possible.


> here, let me explain how I created that diff:
>
> git clone --reference ~/linux-2.6/ git://git.kernel.org/pub/scm/linux=
/kernel/git/davem/net-next.git
> cd net-next/
> git pull git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless=
-drivers-next.git tags/wireless-drivers-next-for-davem-2015-05-21
> emacs drivers/net/wireless/ath/ath10k/mac.c
> git diff > resolution.txt

=46or what it's worth I did:
 git checkout net-next/master
 git merge wireless-drivers-next-for-davem-2015-05-21
 # fix conflicts
 git commit -a
 git show

Merge should essentially yield the same result as your pull.


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
