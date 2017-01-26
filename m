From: Chris Packham <Chris.Packham@alliedtelesis.co.nz>
Subject: Re: [PATCHv3 4/5] arm: mvebu: Add device tree for 98DX3236 SoCs
Date: Thu, 26 Jan 2017 20:24:46 +0000
Message-ID: <cca41061129f4378bfd41a66c8eb71e1@svr-chch-ex1.atlnz.lc>
References: <20170105033641.6212-1-chris.packham@alliedtelesis.co.nz>
 <20170106041517.9589-1-chris.packham@alliedtelesis.co.nz>
 <20170106041517.9589-5-chris.packham@alliedtelesis.co.nz>
 <87inp1zwlg.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Russell King <linux@armlinux.org.uk>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/01/17 04:10, Gregory CLEMENT wrote:=0A=
>> +		internal-regs {=0A=
=0A=
[snip]=0A=
=0A=
>> +=0A=
>> +		dfx-registers {=0A=
> node label=0A=
>=0A=
=0A=
[snip]=0A=
=0A=
>> +		switch {=0A=
> node label=0A=
>=0A=
=0A=
These are peers to the internal-regs, i.e. parts of the SoC with =0A=
mappable windows in the address space. Do they really need a label? =0A=
Their subnodes absolutely need (and have) labels.=0A=
=0A=
