From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe RLT-8139 related)
Date: Thu, 5 Aug 2004 19:21:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805192159.A12203@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.44.0408041915510.14609-100000@silmu.st.jyu.fi> <41120882.40302@marcansoft.com> <41121237.4050305@marcansoft.com> <20040805132233.A7430@electric-eye.fr.zoreil.com> <871xiltxhz.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hector Martin <hector@marcansoft.com>, Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org,
        netdev@oss.sgi.com, brad@brad-x.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Content-Disposition: inline
In-Reply-To: <871xiltxhz.fsf@devron.myhome.or.jp>; from hirofumi@mail.parknet.co.jp on Fri, Aug 06, 2004 at 12:28:40AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> On the final analysis, what was the cause of this problem?

See answer 42

> I found the following in progguide-8100(100).pdf. Does this help something?

It makes sense. The previous code did not allow the ISR to be written under
any circumstance.

--
Ueimor
