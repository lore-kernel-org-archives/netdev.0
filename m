From: Viresh Kumar <viresh.kumar@st.com>
Subject: Re: [PATCH] stmmac: fix kernel crash when device probed for SPEAr
 with DT
Date: Wed, 18 Apr 2012 10:44:59 +0530
Message-ID: <4F8E4DD3.8030908@st.com>
References: <91ea900ce78bb2054d83e0575c16ac70f3f11511.1334654597.git.viresh.kumar@st.com> <4F8E4CEC.9050002@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: spear-devel <spear-devel@list.st.com>,
	"viresh.linux@gmail.com" <viresh.linux@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Deepak SIKRI <deepak.sikri@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:35006 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750995Ab2DRFQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 01:16:41 -0400
In-Reply-To: <4F8E4CEC.9050002@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2012 10:41 AM, Giuseppe CAVALLARO wrote:
> I hoped it was fully tested on SPEAr platforms. at any rate

I am only working for SPEAr3xx with DT support and this patch is must as
without it we have build failures. Haven't tested on any other SPEAr SoCs, they
may require extra pdata fields to be initialized, but that will follow with
their DT support.

-- 
viresh
