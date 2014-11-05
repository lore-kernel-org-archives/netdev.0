From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: Add more checks for get_btc_status callback
Date: Wed, 05 Nov 2014 12:12:36 -0600
Message-ID: <545A6894.7040506@lwfinger.net>
References: <1414625302-3654-1-git-send-email-mopsfelder@gmail.com>	 <5451BED0.2060906@lwfinger.net> <1415178975.5402.66.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>,
	troy_tan@realsil.com.cn
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415178975.5402.66.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2014 03:16 AM, Mike Galbraith wrote:
> On Wed, 2014-10-29 at 23:30 -0500, Larry Finger wrote:
>> On 10/29/2014 06:28 PM, Murilo Opsfelder Araujo wrote:
>>> This is a complement of commit 08054200117a95afc14c3d2ed3a38bf4e345bf78
>>> "rtlwifi: Add check for get_btc_status callback".
>>>
>>> With this patch, next-20141029 at least does not panic with rtl8192se
>>> device.
>>>
>>
>> This patch is OK, but as noted it is not complete.
>>
>> I have patches to fix all the kernel panics for rtl8192se AND rtl8192ce. There
>> are missing parts, but I would prefer submitting mine, which would conflict with
>> this one. For that reason, NACK for this one, and please apply the set I am
>> submitting now.
>
> It's all in there now, but my RTL8191SEvB is still dead.  Squabbling
> with it isn't going all that well either.
>
> As soon as 38506ece rtlwifi: rtl_pci: Start modification for new drivers
> is applied, explosions appear.  Subsequently applying...
>
> 08054200 rtlwifi: Add check for get_btc_status callback
> c0386f15 rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missing get_btc_status
> 50147969 rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw()
> 30c5ccc6 rtlwifi: rtl8192se: Add missing section to read descriptor setting
> 75a916e1 rtlwifi: rtl8192se: Fix firmware loading
>
> ...fixes that mess up, but leaves the interface dead in the same manner
> as if nothing has been reverted.  So it _seems_ the bustage lurks in
> 38506ece somewhere.  Too bad it's non-dinky, and written in wifi-ese :)

Yes, I am aware that rtl8192se is failing, and now that I am back from vacation, 
I am working on the problem. If you want to use the driver with kernel 3.18, 
clone the repo at http://github.com/lwfinger/rtlwifi_new.git and build and 
install either the master or kernel_version branches. Both work.

I am in the process of trying to find what the crucial difference is between 
that repo and the kernel version.

Larry
