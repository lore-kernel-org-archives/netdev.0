From: "David S. Miller" <davem@redhat.com>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 04:43:01 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020423.044301.71627636.davem@redhat.com>
References: <20020423.043534.41652568.davem@redhat.com>
	<Pine.LNX.4.44.0204230803380.7811-100000@simon.ratbox.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: androsyn@ratbox.org
In-Reply-To: <Pine.LNX.4.44.0204230803380.7811-100000@simon.ratbox.org>
List-Id: netdev.vger.kernel.org

   From: Aaron Sethman <androsyn@ratbox.org>
   Date: Tue, 23 Apr 2002 08:07:25 -0400 (EDT)

   You are correct, I was still doing this from my experiences with 2.4.18.
   It came up with 08:00:20:f4:0d:34-7.  I tried it again without setting the
   macaddr, same thing with it hanging after pinging it from another host.
   
   What is strange is that I can ping the gateway just fine, and all the
   sudden it stops right when I ping it from elsewhere.

Can you turn on spin lock debugging for the 2.4.19-preX case?
I bet that will catch what locks it up.

You said this is an SMP box right?
