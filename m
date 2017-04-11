From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next] net: stmmac: set total length of the packet to
 be transmitted in TDES3
Date: Tue, 11 Apr 2017 09:48:57 +0100
Message-ID: <8e26bc0b-62eb-da22-8144-7cae2efe8095@synopsys.com>
References: <20170410183329.28847-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Niklas Cassel <niklass@axis.com>
To: Niklas Cassel <niklas.cassel@axis.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410183329.28847-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Niklas,

Às 7:33 PM de 4/10/2017, Niklas Cassel escreveu:
> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> Field FL/TPL in register TDES3 is not correctly set on GMAC4.
> TX appears to be functional on GMAC 4.10a even if this field is not set,
> however, to avoid relying on undefined behavior, set the length in TDES3.
> 
> The field has a different meaning depending on if the TSE bit in TDES3
> is set or not (TSO). However, regardless of the TSE bit, the field is
> not optional. The field is already set correctly when the TSE bit is set.
> 
> Since there is no limit for the number of descriptors that can be
> used for a single packet, the field should be set to the sum of
> the buffers contained in:
> [<desc with First Descriptor bit set> ... <desc n> ...
> <desc with Last Descriptor bit set>], which should be equal to skb->len.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Sounds fine to me. Did you check for performance improvement? Thanks.

Joao
