From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] stmmac: troubleshoot unexpected bits in des0 & des1
Date: Wed, 24 Jun 2015 08:36:11 +0000
Message-ID: <1435134971.3298.13.camel@synopsys.com>
References: <20150624.001840.1867851321247997506.davem@davemloft.net>
	 <1435133246-15776-1-git-send-email-abrodkin@synopsys.com>
	 <20150624.014440.1731894598101096619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150624.014440.1731894598101096619.davem@davemloft.net>
Content-Language: en-US
Content-ID: <B01072E3FE0A6D43B1C05115FCB2CBE3@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, 2015-06-24 at 01:44 -0700, David Miller wrote:
+AD4- From: Alexey Brodkin +ADw-Alexey.Brodkin+AEA-synopsys.com+AD4-
+AD4- Date: Wed, 24 Jun 2015 11:07:26 +-0300
+AD4- 
+AD4- +AD4-  
+AD4- +AD4- -           priv-+AD4-dma+AF8-tx +AD0- dma+AF8-alloc+AF8-coherent(priv-+AD4-device, 
+AD4- +AD4- txsize +ACo-
+AD4- +AD4- +-           priv-+AD4-dma+AF8-tx +AD0- dma+AF8-zalloc+AF8-coherent(priv-+AD4-device, 
+AD4- +AD4- txsize +ACo-
+AD4- +AD4-                                               sizeof(struct 
+AD4- +AD4- dma+AF8-desc),
+AD4- +AD4-                                               +ACY-priv
+AD4- +AD4- -+AD4-dma+AF8-tx+AF8-phy,
+AD4- +AD4-                                               GFP+AF8-KERNEL)+ADs-
+AD4- 
+AD4- When you change the column at which the openning parenthesis of the
+AD4- function call occurs, you must indent the subsequent lines of the
+AD4- function call such that the all are adjusted to properly start
+AD4- at the very next column after that openning parenthesis.'
+AD4- 
+AD4- Please fix this up for all of the dma+AF8-zalloc+AF8-coherent()
+AD4- transformations.

I thought about that and actually made this change initially but later
reverted it because I noticed dma+AF8-free+AF8-coherent() had parameters not
-aligned/idented properly.

So do you think if I may fix identation of dma+AF8-free+AF8-coherent() while at
it as well or I need to send a separate patch that takes care about
dma+AF8-free+AF8-coherent() solely?

-Alexey