From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed
Date: Fri, 10 Mar 2006 16:51:44 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0603101650390.11559@bizon.gios.gov.pl>
References: <cbec11ac0602091125w5a5a7c6em8462131e9f9b24dc@mail.gmail.com>
 <43EB98B0.4@kernelpanic.ru> <cbec11ac0602091137p4ee233bdgdcfbf3d6cb62a62f@mail.gmail.com>
 <20060310.025912.107001339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-449679675-1142005904=:11559"
Cc: imcdnzl@gmail.com, bb@kernelpanic.ru, jesse.brandeburg@gmail.com,
	yoseph.basri@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751654AbWCJPwB@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060310.025912.107001339.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-449679675-1142005904=:11559
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 10 Mar 2006, David S. Miller wrote:

> From: Ian McDonald <imcdnzl@gmail.com>
> Date: Fri, 10 Feb 2006 08:37:48 +1300
>
>> On 2/10/06, Boris B. Zhmurov <bb@kernelpanic.ru> wrote:
>>> Hello, Ian McDonald.
>>>
>>> On 09.02.2006 22:25 you said the following:
>>>
>>>> Is it possible for you to download 2.6.16-rc2 or similar and see if it
>>>> goes away?
>>>
>>> It'll be better, if I get only patch fixs that problem, not all 2.6.16-=
rc2.
>>
>> Oops I didn't read Jesse's message earlier properly.
>>
>> That patch which probably fixed it is (from his message):
>> I think the commit id that is missing from 2.6.14.X is
>> fb5f5e6e0cebd574be737334671d1aa8f170d5f3
>
> This patch is in the linux-2.6.14 stable tree, I just
> verified this.

So it must be another problem: I had this message with 2.6.15.2:

KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148=
)

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-449679675-1142005904=:11559--
