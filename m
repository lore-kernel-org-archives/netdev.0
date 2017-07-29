From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: stmmac: properly set PS bit in MII
 configurations during reset
Date: Sat, 29 Jul 2017 21:54:40 +0200
Message-ID: <20170729215440.1ee341d9@windsurf.lan>
References: <1493286329-24448-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <deea272a-f0a9-ad0b-4ad6-387723938314@st.com>
        <20170503143032.GA22106@Red>
        <49297ed2-84dc-3e9b-8f40-af915476a091@st.com>
        <20170508211230.58aeead9@free-electrons.com>
        <e8151650-aa51-6713-f10c-b3663763ff78@st.com>
        <20170510091817.58f4e843@free-electrons.com>
        <20170515162734.187845dc@free-electrons.com>
        <20170625143234.358a8ae8@windsurf.home>
        <930a1375-b148-a2c9-7a45-cbc75121866f@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <930a1375-b148-a2c9-7a45-cbc75121866f@st.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Giuseppe,

On Wed, 28 Jun 2017 16:40:51 +0200, Giuseppe CAVALLARO wrote:

> I do not want to change a critical reset function shared among
> different platforms where
> this problem has never met but you are right that we have to find a
> way to proceed in order
> to finalize your work. Let me elaborate your initial patch and I try
> to give you a proposal asap.
> In my mind, we should have a dedicated spear_dma_reset for your case 
> that should be used on
> SPEAr platform driver (or by using st,spear600-gmac compatibility).
> Also your patch did not consider the RMII and (R)GMII cases.

Have you had the chance to cook a different proposal? Alternatively, do
you have some specific hints to give me to make a new proposal that
would be acceptable for you ?

Thanks a lot,

Thomas Petazzoni
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
