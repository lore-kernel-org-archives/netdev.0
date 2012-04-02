From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3.3.0 1/3] net:phy:bcm63xx: remove unnecessary code
Date: Mon, 02 Apr 2012 09:42:25 -0700
Message-ID: <1333384945.15422.14.camel@joe2Laptop>
References: <1333383895-23889-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46745 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752942Ab2DBQm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2012 12:42:27 -0400
In-Reply-To: <1333383895-23889-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-02 at 17:24 +0100, Srinivas KANDAGATLA wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> Compile tested.
> remove unnecessary code that matches this coccinelle pattern
> 
> 	ret = phy_write(x, y , z)
> 	if (ret < 0)
> 		return ret;
> 	return 0;
> 
> As phy_write returns error code, we dont need to do not need extra check
> before returning.

Do these really make any functional difference?
Doesn't the compiler generate the same output?

Many times, there's a code pattern that precedes these
calls has a similar pattern and changing the pattern
for the last call in a sequence can be jarring to a
reader and changing the pattern can sometimes introduce
errors as well.
