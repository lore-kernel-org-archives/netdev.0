From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCHv2 08/11] fec: fix uninitialized rx buffer usage
Date: Wed, 3 Feb 2010 11:38:32 -0700
Message-ID: <fa686aa41002031038i6b058c92g39bcf948cc9cb3ce@mail.gmail.com>
References: <cover.1265173246.git.amit.kucheria@verdurent.com>
	<ccc89dd7a6035abf5a78680404a2b30b9e025353.1265173480.git.amit.kucheria@canonical.com>
	<ec63e5978fd5ac5d308ede5916e648ba925818eb.1265173480.git.amit.kucheria@canonical.com>
	<f10f79e7313ecdeeb59ab881795baedf2430c636.1265173480.git.amit.kucheria@canonical.com>
	<240f12ca87d7666f31263aabc620a9ec197cd8ff.1265173480.git.amit.kucheria@canonical.com>
	<cover.1265173480.git.amit.kucheria@canonical.com> <752ae69adb57d4f73fa011ba380cea1b927b9c8b.1265173480.git.amit.kucheria@canonical.com>
	<e46b06510f7eb6ca51ea8b96335b2d32ec8bf6f8.1265173480.git.amit.kucheria@canonical.com>
	<fa686aa41002030846v5044d585w7f4291f89c4b7ad@mail.gmail.com>
	<37786d4b1002031033s15d0b24et82c3f0e45112ae65@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: List Linux Kernel <linux-kernel@vger.kernel.org>,
	Rob Herring <r.herring@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	s.hauer@pengutronix.de, valentin.longchamp@epfl.ch,
	daniel@caiaq.de, Dinh.Nguyen@freescale.com, bryan.wu@canonical.com
To: Amit Kucheria <amit.kucheria@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <37786d4b1002031033s15d0b24et82c3f0e45112ae65@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2010 at 11:33 AM, Amit Kucheria
<amit.kucheria@canonical.com> wrote:
> On Wed, Feb 3, 2010 at 8:46 AM, Grant Likely <grant.likely@secretlab.ca> wrote:
>> On Tue, Feb 2, 2010 at 10:16 PM, Amit Kucheria
>> <amit.kucheria@canonical.com> wrote:
>>> From: Rob Herring <r.herring@freescale.com>
>>>
>>> The fec driver was enabling receive buffer descriptor without allocating
>>> the buffers. Make sure the buffer descriptors are initialized to not
>>> start receiving packets.
>>>
>>> Open also calls fec_restart after the rx buffers are allocated. With the code
>>> in fec_restart, it zeroes out the buffer descriptors that have just been
>>> setup.
>>
>> fec related patches 8 & 9 look okay to me.
>>
>> g.
>>
>> --
>> Grant Likely, B.Sc., P.Eng.
>> Secret Lab Technologies Ltd.
>
> Can I take that as an Acked-by?

of course.

g.
