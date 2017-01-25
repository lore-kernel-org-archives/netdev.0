From: Amadeusz Slawinski <amadeusz.slawinski@tieto.com>
Subject: Re: [PATCH 2/2] mac80211: use accessor functions to set sta->_flags
Date: Wed, 25 Jan 2017 09:55:57 +0100
Message-ID: <CA+db6Z1OtO4_93KN-YoEaVg79zY5BgX2u0S+8FGVdkWav0iB2g@mail.gmail.com>
References: <1485272531-11587-1-git-send-email-amadeusz.slawinski@tieto.com>
 <1485272531-11587-2-git-send-email-amadeusz.slawinski@tieto.com> <1485272668.1236.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485272668.1236.5.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And yes I did. Somehow managed to ignore those warnings though, sorry
about that.
Rechecked with just first patch and it should still be good. Please
ignore this one ;)

On 24 January 2017 at 16:44, Johannes Berg <johannes@sipsolutions.net> wrot=
e:
> On Tue, 2017-01-24 at 16:42 +0100, Amadeusz S=C5=82awi=C5=84ski wrote:
>> cleanup patch to make use of set_sta_flag()/clear_sta_flag() in
>> places
>> where we access sta->_flags
>>
>> Signed-off-by: Amadeusz S=C5=82awi=C5=84ski <amadeusz.slawinski@tieto.co=
m>
>> ---
>>  net/mac80211/sta_info.c | 12 ++++++------
>>  1 file changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
>> index b6cfcf0..6c9cc2f 100644
>> --- a/net/mac80211/sta_info.c
>> +++ b/net/mac80211/sta_info.c
>> @@ -1855,13 +1855,13 @@ int sta_info_move_state(struct sta_info *sta,
>>       switch (new_state) {
>>       case IEEE80211_STA_NONE:
>>               if (sta->sta_state =3D=3D IEEE80211_STA_AUTH)
>> -                     clear_bit(WLAN_STA_AUTH, &sta->_flags);
>> +                     clear_sta_flag(sta, WLAN_STA_AUTH);
>
> You should try to run this patch sometime :)
>
> johannes
