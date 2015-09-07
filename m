From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] stmmac: fix check for phydev being open
Date: Mon, 7 Sep 2015 21:26:20 +0000
Message-ID: <1441661180.4998.5.camel@synopsys.com>
References: <1441659019-25522-1-git-send-email-abrodkin@synopsys.com>
	 <55EE008E.6040405@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <55EE008E.6040405@cogentembedded.com>
Content-Language: en-US
Content-ID: <059FAEE77F2E3F4CB1598884C7D83335@internal.synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Tue, 2015-09-08 at 00:24 +-0300, Sergei Shtylyov wrote:
+AD4- On 09/07/2015 11:50 PM, Alexey Brodkin wrote:
+AD4- 
+AD4- +AD4- Current implementation via IS+AF8-ERR(phydev) may make no sense because
+AD4- +AD4- of+AF8-phy+AF8-attach() returns NULL on failure instead of error value.
+AD4- 
+AD4-     Not of+AF8-phy+AF8-connect()?

I already noticed this misspelling - it came from my exploration of
what happens inside of+AF8-phy+AF8-connect(). So sort of braindump.

I will fix in v3 re-spin.

-Alexey