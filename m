From: viresh kumar <viresh.kumar2@arm.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 09:45:51 +0100
Message-ID: <4FE18DBF.1070306@arm.com>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au> <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com> <4FE18502.6040409@arm.com> <20120620.012037.783895812206310043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: "bhupesh.sharma@st.com" <bhupesh.sharma@st.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"federico.vaga@gmail.com" <federico.vaga@gmail.com>,
	"giancarlo.asnaghi@st.com" <giancarlo.asnaghi@st.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"spear-devel@list.st.com" <spear-devel@list.st.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120620.012037.783895812206310043.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/06/12 09:20, David Miller wrote:
> From: viresh kumar <viresh.kumar2@arm.com>
> Date: Wed, 20 Jun 2012 09:08:34 +0100
>
>> > Please see following patchset from me, that got applied in linux-next
>> >
>> > https://lkml.org/lkml/2012/4/24/154
>> >
>> > Please check if this patchset is present in your build repo. I believe it should be
>> > there. If it is, then you shouldn't get these errors.
> Well, then Stephen shouldn't get those errors either.
>
> But obviously he did.

Surprised. I am not able to get why this happen. Because we don't have HAVE_CLK defined
for x86_64, then the inline routines like following should come into play:

static inline unsigned long clk_get_rate(struct clk *clk)
{
        return 0;
}


Is there any tricky part for such routines with drivers compiled as modules?

--
Viresh

-- IMPORTANT NOTICE: The contents of this email and any attachments are confidential and may also be privileged. If you are not the intended recipient, please notify the sender immediately and do not disclose the contents to any other person, use it for any purpose, or store or copy the information in any medium.  Thank you.
