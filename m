From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 06/22] staging: rtl8723bs: Fix various errors in
 os_dep/ioctl_cfg80211.c
Date: Sun, 9 Apr 2017 10:46:20 -0500
Message-ID: <0394a00a-9a07-b959-1823-af03dd023ef4@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
 <20170408160745.14328-7-Larry.Finger@lwfinger.net>
 <1491751698.10783.18.camel@hadess.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, jes.sorensen@gmail.com,
 hdegoede@redhat.com
To: Bastien Nocera <hadess@hadess.net>, gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1491751698.10783.18.camel@hadess.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 04/09/2017 10:28 AM, Bastien Nocera wrote:
> On Sat, 2017-04-08 at 11:07 -0500, Larry Finger wrote:
>> Smatch lists the following:
>>
>>   CHECK   drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:470
>> rtw_cfg80211_ibss_indicate_connect() error: we previously assumed
>> 'scanned' could be null (see line 466)
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:942
>> rtw_cfg80211_set_encryption() warn: inconsistent indenting
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:955
>> rtw_cfg80211_set_encryption() error: buffer overflow 'psecuritypriv-
>>> dot11DefKey' 4 <= 4
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:1017
>> rtw_cfg80211_set_encryption() error: buffer overflow 'padapter-
>>> securitypriv.dot118021XGrpKey' 5 <= 5
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:1216
>> cfg80211_rtw_set_default_key() warn: inconsistent indenting
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2498
>> rtw_cfg80211_monitor_if_xmit_entry() error: we previously assumed
>> 'skb' could be null (see line 2495)
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2850
>> cfg80211_rtw_start_ap() warn: if statement not indented
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2860
>> cfg80211_rtw_start_ap() warn: if statement not indented
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:3417
>> rtw_cfg80211_preinit_wiphy() warn: inconsistent indenting
>> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:3547
>> rtw_wdev_alloc() info: ignoring unreachable code.
>>
>> The indenting warnings were fixed by simple white space changes.
>>
>> The section where 'scanned' could be null required an immediate exit
>> from
>> the routine at that point. A similar fix was required where 'skb'
>> could be null.
>>
>> The two buffer overflow errors were caused by off-by-one errors.
>> While
>> locating these problems, another one was found in
>> os_dep/ioctl_linux.c.
>
> Could you please split those up into patches that fix one kind of
> problem? Makes it easier to review.

These patches were merged earlier today. Thanks for the reviews.

Larry
