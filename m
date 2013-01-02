From: Steven Wang <steven.wang@digilentinc.com>
Subject: RE: Support for Marvell 88E1510 and 88E1116R
Date: Wed, 2 Jan 2013 11:16:53 -0800
Message-ID: <BF617F5A412EFC46879ABC89757850DE02692A298149@SERVER.digilent.local>
References: <50E404BC.3010604@monstr.eu> <50E45B74.70301@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linn <linnj@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>,
	Sam Bobrowicz <SBobrowicz@digilentinc.com>,
	Rick Hoover <RHoover@digilentinc.com>
To: Lars-Peter Clausen <lars@metafoo.de>,
	"monstr@monstr.eu" <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50E45B74.70301@metafoo.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Michal,

We do have the Ethernet support for 88E1510 (used on ZedBoard) in our repository. The commit is
https://github.com/Digilent/linux-digilent/commit/ae635e5fff35e9fe5928b4aca7264a1e5313a6b8
Or, I can send the patch to you if you need.

Best Regards,
Steve

-----Original Message-----
From: Lars-Peter Clausen [mailto:lars@metafoo.de] 
Sent: Wednesday, January 2, 2013 8:08 AM
To: monstr@monstr.eu
Cc: netdev@vger.kernel.org; Christian Hohnstaedt; Srinivas Kandagatla; David Miller; LKML; John Linn; Michal Simek; Sam Bobrowicz; Rick Hoover; Steven Wang
Subject: Re: Support for Marvell 88E1510 and 88E1116R

On 01/02/2013 10:58 AM, Michal Simek wrote:
> Hi guys,
> 
> just a question regarding to Marvell 88e1510 and 88E1116R phys.
> We have these phys on the arm zynq board and would like to add
> support to the kernel. Is there any repository with these phys?
> If yes, when are you going to add them to the mainline?
> 
> If there is not, I can send patches for them.
> (I am not the author of that patches just trying to clean our
> repository and add patches to the mainline)

I think the 88E1510 support was added by the Digilent guys (added to Cc) and
the 88E1116R support came from within Xilinx.

I agree that these are pretty straight forward changes and could go upstream in
their current form.

- Lars
