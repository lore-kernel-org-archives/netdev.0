From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] stmmac: fix check for phydev being open
Date: Tue, 8 Sep 2015 00:24:30 +0300
Message-ID: <55EE008E.6040405@cogentembedded.com>
References: <1441659019-25522-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1441659019-25522-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2015 11:50 PM, Alexey Brodkin wrote:

> Current implementation via IS_ERR(phydev) may make no sense because
> of_phy_attach() returns NULL on failure instead of error value.

    Not of_phy_connect()?

> Still for checking result of phy_connect() IS_ERR() is useful.
>
> To address both situations we use combined IS_ERR_OR_NULL() check.
>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> Cc: David Miller <davem@davemloft.net>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

MBR, Sergei
