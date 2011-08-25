From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Subject: Re: [omega-g1:11110] Re: [PATCH] net: configurable sysctl parameter
 "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Thu, 25 Aug 2011 13:46:58 +0900
Message-ID: <4E55D3C2.40308@ctc-g.co.jp>
References: <4E4E2CCD.6050809@ctc-g.co.jp>
 <20110819.024326.598275465899000817.davem@davemloft.net>
 <4E51A3F0.5010500@ctc-g.co.jp>
 <20110822.113544.28950168095176936.davem@davemloft.net>
Reply-To: jun.kondo@ctc-g.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20110822.113544.28950168095176936.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, once the transmission buffer becomes full, it is not
possible to write again unless there is one third of free space
in the transmission buffer.

Our modification request is not intending to change the behavior
of the OS itself, but making the value "one third" to be
configurable, not fixed.

Thus it would be still possible to set the value to 1/3.

So, could you please tell us why it is not acceptable to make
it configurable, and what is the persistence with the value of
1/3?
