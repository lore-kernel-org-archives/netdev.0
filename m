From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH] net: stmmac: add dcrs parameter
Date: Tue, 26 Aug 2014 07:35:53 -0500
Message-ID: <CAOwfj2MMJCYyqD9++MpbRZohzBXyX16fJY-FaT+8H2gZyJd9MA@mail.gmail.com>
References: <1408967442-2724-1-git-send-email-lftan@altera.com>
	<CAGb2v65fi=D_TQBSospft4T5OrBCj5TwQfgtkX=11M8TWFftYg@mail.gmail.com>
	<53FB313C.9010808@st.com>
	<CAOwfj2Oyy8EGxPhgJcgeGPMm3tJ9-fGOh5h7jU8q4_BO=vWrTA@mail.gmail.com>
	<53FC1D68.1000600@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens@csie.org>, Ley Foon Tan <lftan@altera.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	LeyFoon Tan <lftan.linux@gmail.com>,
	Vince Bridgers <vbridger@altera.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53FC1D68.1000600@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peppe,

>>
>> In the Synopsys EMAC case, carrier sense is used to stop transmitting
>> if no carrier is sensed during a transmission. This is only useful if
>> the media in use is true half duplex media (like obsolete 10Base2 or
>> 10Base5). If no one in using true half duplex media, then is it
>> possible to set this disable by default? If we're not sure, then
>> having an option feels like the right thing to do.
>
>
> Indeed this is what I had done in the patch.
>
> http://git.stlinux.com/?p=stm/linux-sh4-2.6.32.y.git;a=commit;h=b0b863bf65c36dc593f6b7b4b418394fd880dae2
>
> Also in case of carrier sense the frame will be dropped in any case
> later.
>
> Let me know if you Acked this patch so I will rebase it on
> net.git and I send it soon
>
> peppe
>

Yes, this looks good to me. I don't expect anyone is using 10Base2 or
10Base5 anymore, so it's ok to disable DCRS by default.

ack

All the best,

Vince
