From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Fri, 27 Feb 2015 17:22:35 +0000
Message-ID: <54F0A7DB.9070103@linn.co.uk>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk> <20150225151945.GB7703@localhost.localdomain> <20150225170127.GD7703@localhost.localdomain> <54EE0268.2040201@linn.co.uk> <20150225173053.GE7703@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150225173053.GE7703@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 25/02/15 17:30, Richard Cochran wrote:
>> I need some more time to study your other suggestions regarding the
>> PHY timestamping framework.
>
>  From my (limited) understanding of your HW device, I should think that
> it will work.  The PHY time stamping subsystem is not the most obvious
> code in the world.  Please feel free to ask if you have any questions.
>

To summarize (and confirm my understanding) your suggestion is for the
sniffer to be configured to match PTP packets and (similarly to the
dp83640) return the Message Type and Sequence Id fields that will allow
them to be matched to an sk_buf that has been passed from the stack.
Then the sk_buf can be timestamped using the sniffer timestamp.

The H/W does have the capability to do that. However, in order to
implement it there will be some architectural changes needed
in the kernel. This module cannot really pretend to be a PHY.
In the real world it sits between the MAC and the PHY.

> Thanks,
> Richard
>

Thanks,
Stathis
