From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next.git 2/7] stmmac: review barriers
Date: Thu, 04 Apr 2013 08:08:14 -0700
Message-ID: <1365088094.13853.67.camel@edumazet-glaptop>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
	 <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com>
	 <20130403085106.GA2039@localhost.localdomain> <515D1863.2070801@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shiraz HASHIM <shiraz.hashim@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>,
	sergei.shtylyov@cogentembedded.com
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:37959 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762713Ab3DDPIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 11:08:18 -0400
Received: by mail-da0-f41.google.com with SMTP id w4so1170338dam.0
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 08:08:18 -0700 (PDT)
In-Reply-To: <515D1863.2070801@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 08:06 +0200, Giuseppe CAVALLARO wrote:

> In fact, if we can demonstrate that barriers are needed no problem to
> keep them in the code. Otherwise I prefer to remove them.
> 
> What do you think?

I think there are needed, and its really obvious.

Now maybe your arch can define wmb() as a pure compiler barrier(), but
thats a completely different patch.
