From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] bonding: Use do_div to divide 64 bit numbers
Date: Fri, 24 Jan 2014 18:27:36 +0000
Message-ID: <52E2B098.1060509@citrix.com>
References: <1390502838-21581-1-git-send-email-zoltan.kiss@citrix.com> <52E17F40.4040004@redhat.com> <52E18720.4060008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52E18720.4060008@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/01/14 21:18, Nikolay Aleksandrov wrote:
>> Hi Zoltan,
>> Thanks for fixing this, a few comments though:
>> bond->params.miimon can be 0 here that's why there's a check afterwards,
>> also please separate the local variable definitions from the body with a
>> new line.
>> The same applies for downdelay.
>>
>> Nik
> In fact since we don't need the u64 and newval->value is limited to
> INT_MAX, can't we simply cast it to (int) and avoid the do_div entirely ?
Yep, that's even better, thanks for fixing it!

Zoli
