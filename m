From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3.3.0 1/3] net:phy:bcm63xx: remove unnecessary code
Date: Mon, 02 Apr 2012 10:02:37 -0700
Message-ID: <1333386157.15422.21.camel@joe2Laptop>
References: <1333383895-23889-1-git-send-email-srinivas.kandagatla@st.com>
	 <1333384945.15422.14.camel@joe2Laptop> <4F79D91A.2030403@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54879 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751731Ab2DBRCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2012 13:02:39 -0400
In-Reply-To: <4F79D91A.2030403@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-02 at 17:51 +0100, Srinivas KANDAGATLA wrote:
> On 02/04/12 17:42, Joe Perches wrote:
> > On Mon, 2012-04-02 at 17:24 +0100, Srinivas KANDAGATLA wrote:
> > Do these really make any functional difference?
> No it does not make any functional difference.
> > Doesn't the compiler generate the same output?
> I think it will not generate same output.

Yes, you are right.  The code currently returns 0 for
non-error cases and you've changed it to possibly
return a positive value.

Have you checked all the callers to make sure this
doesn't introduce a new defect?
