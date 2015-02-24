From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH v3 3/3] Linn Ethernet packet sniffer driver
Date: Tue, 24 Feb 2015 09:44:33 +0000
Message-ID: <54EC4801.3080407@linn.co.uk>
References: <cover.1424698609.git.stathis.voukelatos@linn.co.uk>	<34013795c99ef50fac3d2c72717971563148578c.1424698609.git.stathis.voukelatos@linn.co.uk> <20150223.163854.880151768241069377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150223.163854.880151768241069377.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 23/02/15 21:38, David Miller wrote:
> From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
> Date: Mon, 23 Feb 2015 14:26:22 +0000
>
>> Driver for the Ethernet Mii packet sniffer H/W module found in
>> the IMG Pistachio SoC.
>>
>> Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
>
> You really have to explain what this thing does, how it is used,
> what APIs are made use of to maniulate this device, etc.
>
> Nobody knows what the packet sniffer module by your company is.
>

I tried to provide a description of the device in the cover letter. I 
will expand it and also include it in a suitable place in the actual 
source.

> I also anticipate that once you describe adequately how this thing
> behaves I won't like it, and I'll prefer that you integrate support
> for your device using an exising facility such as AF_PACKET,
> extending it if need be.
>

The driver actually relies on AF_PACKET for accessing the device. I will 
add some documentation to make the usage and API clearer.

> I am very far away from applying this series at this point, it needs
> a lot more work and explanations.
>

Thank you,
Stathis
