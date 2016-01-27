From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: [PATCH 4.1] [media] media/vivid-osd: fix info leak in ioctl
Date: Wed, 27 Jan 2016 16:59:57 +0900
Message-ID: <56A878FD.7070905@jp.fujitsu.com>
References: <1453718538-21691-1-git-send-email-machida.yuki@jp.fujitsu.com>
 <20160125171844.GA27264@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Salva_Peir=c3=b3?= <speirofr@gmail.com>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:14848 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760AbcA0IAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 03:00:06 -0500
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 31835AC03C0
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 16:59:58 +0900 (JST)
In-Reply-To: <20160125171844.GA27264@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On 2016=E5=B9=B401=E6=9C=8826=E6=97=A5 02:18, Greg KH wrote:
> On Mon, Jan 25, 2016 at 07:42:18PM +0900, Yuki Machida wrote:
>> commit eda98796aff0d9bf41094b06811f5def3b4c333c upstream.
>>
>> The vivid_fb_ioctl() code fails to initialize the 16 _reserved bytes=
 of
>> struct fb_vblank after the ->hcount member. Add an explicit
>> memset(0) before filling the structure to avoid the info leak.
>>
>> This fixes CVE-2015-7884.
>>
>> Signed-off-by: Salva Peir=C3=B3 <speirofr@gmail.com>
>> Signed-off-by: Hans Verkuil <hans.verkuil@cisco.com>
>> Signed-off-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
>> Signed-off-by: Yuki Machida <machida.yuki@jp.fujitsu.com>
>> ---
>>   drivers/media/platform/vivid/vivid-osd.c | 1 +
>>   1 file changed, 1 insertion(+)
>
> <formletter>
>
> This is not the correct way to submit patches for inclusion in the
> stable kernel tree.  Please read Documentation/stable_kernel_rules.tx=
t
> for how to do this properly.

Thank you for your advice.
I will check stable_kernel_rules.txt again.

> </formletter>
>
