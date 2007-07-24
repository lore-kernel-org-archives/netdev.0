From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Tue, 24 Jul 2007 11:35:58 +0200
Message-ID: <20070724093558.GB9285@postel.suug.ch>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com> <46A0BFFF.5020000@trash.net> <46A0DF91.6000508@st.com> <20070723102909.GA9285@postel.suug.ch> <46A4DB34.4040502@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59428 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759363AbXGXJfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 05:35:38 -0400
Content-Disposition: inline
In-Reply-To: <46A4DB34.4040502@st.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Richard MUSIL <richard.musil@st.com> 2007-07-23 18:45
> I have been giving it a second thought and came up with something more
> complex. The idea is to have locking granularity at the level of
> individual families.

I agree in general, it would make up a better solution.

However, your initial patch allows operations and families to be
unregistered while message of the same family are being processed
which must not be allowed.

Please provide a new overall patch which is not based on your
initial patch so I can review your idea properly.
