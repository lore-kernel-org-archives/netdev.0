From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Mon, 03 Jun 2013 16:26:45 +0800
Message-ID: <51AC5345.6020904@cn.fujitsu.com>
References: <201304250822.38944.a.miskiewicz@gmail.com> <517A0A84.40102@cn.fujitsu.com> <517A0BE2.9080503@redhat.com> <201305290029.35303.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	Balakumaran Kannan <kumaran.4353@gmail.com>,
	Maruthi Thotad <Maruthi.Thotad@ap.sony.com>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50911 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab3FCIZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 04:25:02 -0400
In-Reply-To: <201305290029.35303.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2013 06:29 AM, Arkadiusz Miskiewicz wrote:
> On Friday 26 of April 2013, Jason Wang wrote:
>> On 04/26/2013 01:03 PM, Gao feng wrote:
>>> On 04/25/2013 11:04 PM, Arkadiusz Miskiewicz wrote:
>>>> On Thursday 25 of April 2013, Gao feng wrote:
>>>>> We forget to release the reference of tun device in tun_recvmsg.
>>>>> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
>>>>> (tuntap: move socket to tun_file)
>>>>
>>>> Hm, still hitting the problem even with the patch - dmesg:
>>> Ok, seams there are another problems we haven't discovered.
>>> it's excellent if you can find out which commit introduces this
>>> bug by git bisect.
>>>
>>> Thanks!
>>
>> Yes, bisect will be helpful. If you could not do it, please tell me the
>> steps to reproduce the issue and the tree you used. I just test with
>> net.git and net-next.git with a tap device created by tunctl, didn't
>> meet the issue.
> 
> Took a while. Suspected patch is below. I'm running fresh linus git
> (3.10.0-rc3-00046-g58f8bbd) with the patch reverted and couldn't
> reproduce problem anymore after several tries (will do more testing
> in meantime).

Thanks for your helpful work :)
I already send a patch to fix this problem.

> 
> My tap0 has ipv6 addresses (with link scope only). openvpn 2.3.1.

Indeed, not only tap/tun device, the other net devices can trigger
this problem too.


Thanks!
