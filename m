From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/3] net: stmmac:sti: Add STi SOC glue driver.
Date: Thu, 06 Feb 2014 19:53:42 -0800 (PST)
Message-ID: <20140206.195342.1998479313077409827.davem@davemloft.net>
References: <1391428787-27143-1-git-send-email-srinivas.kandagatla@st.com>
	<1391428868-27245-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net, linux@arm.linux.org.uk,
	stuart.menefy@st.com, peppe.cavallaro@st.com,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel@stlinux.com
To: srinivas.kandagatla@st.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1391428868-27245-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <srinivas.kandagatla@st.com>
Date: Mon, 3 Feb 2014 12:01:08 +0000

> +	res = platform_get_resource_byname(pdev,
> +				IORESOURCE_MEM, "sti-ethconf");

This is not the correct way to format multi-line function calls,
you'll need to fix this up in this entire series.

The arguments on the second and subsequent lines must start at
the first column after the openning parenthesis of the function
call.  You must use the appropriate number of both space and
TAB characters necessary to do so.

If you're only using TAB characters to indent, you're doing it
wrong.

Thank you.
