From: Matthias May <matthias.may@neratec.com>
Subject: Re: [PATCH 4.9.0-rc5] AR9300 calibration problems with antenna
 selected
Date: Mon, 21 Nov 2016 15:11:34 +0100
Message-ID: <e1d1516a-2d1c-b696-b121-9b55ba36460b@neratec.com>
References: <m3wpg52hii.fsf@t19.piap.pl>
 <61055e757c5645dfb69da3fc555cbcf5@aptaiexm02f.ap.qualcomm.com>
 <2ea016e563f5db553f201a7d4205c2c0@codeaurora.org>
 <m3d1hp2b0z.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: miaoqing@codeaurora.org,
        ath9k-devel <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Krzysztof_Ha=c5=82asa?= <khalasa@piap.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m3d1hp2b0z.fsf@t19.piap.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/11/16 14:54, Krzysztof Hałasa wrote:
> miaoqing@codeaurora.org writes:
> 
>>> rmmod ath9k
>>> modprobe ath9k
>>> iw dev wlan0 set type ibss
>>> iw phy phyX set antenna 2
>>
>> 2 is a bad mask. We use bitmap, the valid masks are 1, 3, 7.
> 
> Thanks for your response.
> 
> I have two antenna connections (and a single antenna). Is it possible to
> select the secondary antenna connector only? How?
> 

No this is not really possible.
We have been playing around with this two, three years ago with this.
There are just too many things which rely on chain0
Noise calibration, DFS, Temperature measurement, Spectrum measurement
are just a few of the things I remember which don't work realiably anymore.
See [1] for more.

BR
Matthias

[1]
http://ath9k-devel.ath9k.narkive.com/QZcobwy1/ath9k-deaf-qca9558-when-setting-rxchainmask#post1
