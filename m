From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.4.21
Date: Thu, 17 Jul 2003 15:34:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F17245D.9040806@us.ibm.com>
References: <Pine.LNX.4.44.0307171336430.1353-100000@DYN318430.beaverton.ibm.com>	<Pine.LNX.4.44.0307171413100.1353-100000@DYN318430.beaverton.ibm.com> <20030718.002209.104303756.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, kuznet@ms2.inr.ac.ru, davem@redhat.com,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030718.002209.104303756.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Hmm, you seems still misunderstanding some of our points. :-p
> Alexey says we may want to use ifi_family for per-interface L3 information
> including M/O bits. 

It is not a misunderstanding, I had replied to that mail saying that I don't
have any knowledge of using this new interface. If you prefer, I can split the
patch for prefix list vs O/M bits so that the former is accepted without any
issues. Someone else can modify the O/M to suit new needs. Does that sound OK
with you ?

 > At least, new RTM_xxx should not be restricted to get such flags.

That's why I had suggested that we can use RTM_GETLNKINFO with more information,
like RTA_IFFLAGS, and other things like stats or whatever. That can be done
easily enough and still be functionally complete. I just don't have any idea
about this new interface.

Is this still a problem ?

thanks,

- KK
