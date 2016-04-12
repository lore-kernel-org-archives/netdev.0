From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP reaching to maximum throughput after a long time
Date: Tue, 12 Apr 2016 08:04:52 -0700
Message-ID: <570D0E94.3080006@candelatech.com>
References: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com> <1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	open list <linux-kernel@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: "Machani, Yaniv" <yanivma@ti.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/12/2016 07:52 AM, Eric Dumazet wrote:
> On Tue, 2016-04-12 at 12:17 +0000, Machani, Yaniv wrote:
>> Hi,
>> After updating from Kernel 3.14 to Kernel 4.4 we have seen a TCP performance degradation over Wi-Fi.
>> In 3.14 kernel, TCP got to its max throughout after less than a second, while in the 4.4  it is taking ~20-30 seconds.
>> UDP TX/RX and TCP RX performance is as expected.
>> We are using a Beagle Bone Black and a WiLink8 device.
>>
>> Were there any related changes that might cause such behavior ?
>> Kernel configuration and sysctl values were compared, but no significant differences have been found.

If you are using 'Cubic' TCP congestion control, then please try something different.
It was broken last I checked, at least when used with the ath10k driver.

https://marc.info/?l=linux-netdev&m=144405216005715&w=2

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
