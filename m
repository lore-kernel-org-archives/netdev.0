From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
	driver.
Date: Sun, 11 Oct 2009 10:05:20 +0200
Message-ID: <1ba2fa240910110105x33fb251ar3437dd5fee552735@mail.gmail.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1ba2fa240910100238s709c31d3s6cb612f502b1086f@mail.gmail.com>
	 <20091010.185852.133969433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-mmc@vger.kernel.org,
	yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <20091010.185852.133969433.davem@davemloft.net>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 11, 2009 at 3:58 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Tomas Winkler <tomasw@gmail.com>
> Date: Sat, 10 Oct 2009 11:38:50 +0200
>
>> On Wed, Sep 23, 2009 at 1:38 AM, Tomas Winkler <tomas.winkler@intel.=
com> wrote:
>>> This patch adds Intel Wireless MultiCom 3200 top driver.
>>> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
>>> Top driver is responsible for device initialization and firmware do=
wnload.
>>> Firmware handled by top is responsible for top itself and
>>> as well as bluetooth and GPS coms. (Wifi and WiMax provide their ow=
n
>>> firmware)
>>> In addition top driver is used to retrieve firmware logs
>>> and supports other debugging features
>>>
>>> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
>>
>> Dave,
>> are you going to merge this one?
>> iwmc3200wifi and i200m-sdio which are already merged are usless with=
out it
>
> If it's not in netdev patchwork, I don't plan to add it.
>
> If it is in patchwork, then it's in my backlog and I'll get to it.
>
> People should never really have to ask me these questions, that's one
> of the main points of:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0http://patchwork.ozlabs.org/project/netdev=
/list/
>
> You can always see there what's "pending".

Just close my eyes and there is new game to play. :)
It's not in the patchwork, so is there any reason you are not planning
to add it.   The patch intention was for net-next, it looks like
I didn't mark it as such, my fault.

My primary concern is that the driver lies under misc directory so
it's not clear it should be in netdev.
This chip has 4 coms, with drivers under wireless, wimax, serial,
bluetooth. and misc.  Eech of them
handled by different mailing list and sub tree. The major  problem is
the top driver as other 4 comps depends
on it so I'm looking for place to refer to. Please if you have no
intention to handle it or have more concern please  let me know.

Thanks
Tomas
