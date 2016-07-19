From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Tue, 19 Jul 2016 13:43:26 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C19F7C@SHSMSX103.ccr.corp.intel.com>
References: <20160718194357.GL5871@two.firstfloor.org>
	<1468878674.1778899.669950273.69750E32@webmail.messagingengine.com>
	<37D7C6CF3E00A74B8858931C1DB2F07712C19A4A@SHSMSX103.ccr.corp.intel.com>
 <20160718.220342.805963245855552246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@l
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718.220342.805963245855552246.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> > Yes, rtnl will bring some overheads. But the configuration is one time
> > thing for application or socket. It only happens on receiving first
> > packet.
> 
> Thanks for destroying our connection rates.
> 
> This kind of overhead is simply unacceptable.

If so, I think I can make the configuration asynchronized for next
version. The connection rate should not be destroyed.

Thanks,
Kan
